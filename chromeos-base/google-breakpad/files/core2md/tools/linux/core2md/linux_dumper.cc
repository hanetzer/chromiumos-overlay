// Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// This file is a patched version from Google Breakpad revision 598 to
// support core dump to minidump conversion.  Original copyright follows.
//
// Copyright (c) 2009, Google Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// This code deals with the mechanics of getting information about a crashed
// process. Since this code may run in a compromised address space, the same
// rules apply as detailed at the top of minidump_writer.h: no libc calls and
// use the alternative allocator.

#include "tools/linux/core2md/linux_dumper.h"

#include <assert.h>
#include <limits.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <unistd.h>
#include <elf.h>
#include <errno.h>
#include <fcntl.h>
#include <link.h>

#include <sys/types.h>
#include <sys/procfs.h>
#include <sys/ptrace.h>
#include <sys/wait.h>

#include <algorithm>

#include "client/linux/minidump_writer/directory_reader.h"
#include "client/linux/minidump_writer/line_reader.h"
#include "common/linux/file_id.h"
#include "common/linux/linux_libc_support.h"
#include "common/linux/linux_syscall_support.h"
#include "tools/linux/core2md/core_reader.h"

static const char kMappedFileUnsafePrefix[] = "/dev/";

// Suspend a thread by attaching to it.
static bool SuspendThread(pid_t pid) {
  // This may fail if the thread has just died or debugged.
  errno = 0;
  if (sys_ptrace(PTRACE_ATTACH, pid, NULL, NULL) != 0 &&
      errno != 0) {
    return false;
  }
  while (sys_waitpid(pid, NULL, __WALL) < 0) {
    if (errno != EINTR) {
      sys_ptrace(PTRACE_DETACH, pid, NULL, NULL);
      return false;
    }
  }
  return true;
}

// Resume a thread by detaching from it.
static bool ResumeThread(pid_t pid) {
  return sys_ptrace(PTRACE_DETACH, pid, NULL, NULL) >= 0;
}

inline static bool IsMappedFileOpenUnsafe(
    const google_breakpad::MappingInfo* mapping) {
  // It is unsafe to attempt to open a mapped file that lives under /dev,
  // because the semantics of the open may be driver-specific so we'd risk
  // hanging the crash dumper. And a file in /dev/ almost certainly has no
  // ELF file identifier anyways.
  return my_strncmp(mapping->name,
                    kMappedFileUnsafePrefix,
                    sizeof(kMappedFileUnsafePrefix) - 1) == 0;
}

namespace google_breakpad {

LinuxDumper::LinuxDumper(int pid)
    : pid_(pid),
      threads_suspended_(false),
      threads_(&allocator_, 8),
      mappings_(&allocator_),
      override_procfs_prefix_(NULL),
      core_path_(NULL),
      core_buffer_(NULL) {
}

LinuxDumper::~LinuxDumper() {
  if (core_buffer_ != NULL) {
    munmap(core_buffer_, core_.length());
  }
}

bool LinuxDumper::Init() {
  if (!EnumerateThreads(&threads_))
    return false;
  if (core_path_ != NULL && !LoadCoreFile())
    return false;
  if (!EnumerateMappings(&mappings_))
    return false;
  return true;
}

bool LinuxDumper::ThreadsSuspend() {
  // Nothing to suspend if we're reading a core file.
  if (IsPostMortem())
    return true;
  if (threads_suspended_)
    return true;
  bool good = true;
  for (size_t i = 0; i < threads_.size(); ++i)
    good &= SuspendThread(threads_[i]);
  threads_suspended_ = true;
  return good;
}

bool LinuxDumper::ThreadsResume() {
  // Nothing to resume if we're reading a core file.
  if (IsPostMortem())
    return true;
  if (!threads_suspended_)
    return false;
  bool good = true;
  for (size_t i = 0; i < threads_.size(); ++i)
    good &= ResumeThread(threads_[i]);
  threads_suspended_ = false;
  return good;
}

void
LinuxDumper::BuildProcPath(char* path, pid_t pid, const char* node) const {
  assert(path);
  if (!path) {
    return;
  }

  path[0] = '\0';

  const unsigned pid_len = my_int_len(pid);

  assert(node);
  if (!node) {
    return;
  }

  size_t node_len = my_strlen(node);
  assert(node_len < NAME_MAX);
  if (node_len >= NAME_MAX) {
    return;
  }

  assert(node_len > 0);
  if (node_len == 0) {
    return;
  }

  size_t total_length;
  if (override_procfs_prefix_ != NULL) {
    total_length = strlen(override_procfs_prefix_) + 1 + node_len;
  } else {
    assert(pid > 0);
    if (pid <= 0) {
      return;
    }
    total_length = 6 + pid_len + 1 + node_len;
  }

  assert(total_length < NAME_MAX);
  if (total_length >= NAME_MAX) {
    return;
  }

  if (!override_procfs_prefix_) {
    memcpy(path, "/proc/", 6);
    my_itos(path + 6, pid, pid_len);
    memcpy(path + 6 + pid_len, "/", 1);
    memcpy(path + 6 + pid_len + 1, node, node_len);
  } else {
    int override_procfs_prefix_len = strlen(override_procfs_prefix_);
    memcpy(path, override_procfs_prefix_, override_procfs_prefix_len);
    memcpy(path + override_procfs_prefix_len, "/", 1);
    memcpy(path + override_procfs_prefix_len + 1, node, node_len);
  }
  memcpy(path + total_length, "\0", 1);
}

bool
LinuxDumper::ElfFileIdentifierForMapping(unsigned int mapping_id,
                                         uint8_t identifier[sizeof(MDGUID)])
{
  assert(mapping_id < mappings_.size());
  my_memset(identifier, 0, sizeof(MDGUID));
  const MappingInfo* mapping = mappings_[mapping_id];
  if (IsMappedFileOpenUnsafe(mapping)) {
    return false;
  }
  int fd = sys_open(mapping->name, O_RDONLY, 0);
  if (fd < 0)
    return false;
  struct kernel_stat st;
  if (sys_fstat(fd, &st) != 0) {
    sys_close(fd);
    return false;
  }
#if defined(__x86_64)
#define sys_mmap2 sys_mmap
#endif
  void* base = sys_mmap2(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
  sys_close(fd);
  if (base == MAP_FAILED)
    return false;

  bool success = FileID::ElfFileIdentifierFromMappedFile(base, identifier);
  sys_munmap(base, st.st_size);
  return success;
}

void*
LinuxDumper::FindBeginningOfLinuxGateSharedLibrary(const pid_t pid) const {
  char auxv_path[NAME_MAX];
  BuildProcPath(auxv_path, pid, "auxv");

  // If BuildProcPath errors out due to invalid input, we'll handle it when
  // we try to sys_open the file.

  // Find the AT_SYSINFO_EHDR entry for linux-gate.so
  // See http://www.trilithium.com/johan/2005/08/linux-gate/ for more
  // information.
  int fd = sys_open(auxv_path, O_RDONLY, 0);
  if (fd < 0) {
    return NULL;
  }

  elf_aux_entry one_aux_entry;
  while (sys_read(fd,
                  &one_aux_entry,
                  sizeof(elf_aux_entry)) == sizeof(elf_aux_entry) &&
         one_aux_entry.a_type != AT_NULL) {
    if (one_aux_entry.a_type == AT_SYSINFO_EHDR) {
      close(fd);
      return reinterpret_cast<void*>(one_aux_entry.a_un.a_val);
    }
  }
  close(fd);
  return NULL;
}

bool
LinuxDumper::EnumerateMappings(wasteful_vector<MappingInfo*>* result) const {
  char maps_path[NAME_MAX];
  BuildProcPath(maps_path, pid_, "maps");

  // linux_gate_loc is the beginning of the kernel's mapping of
  // linux-gate.so in the process.  It doesn't actually show up in the
  // maps list as a filename, so we use the aux vector to find it's
  // load location and special case it's entry when creating the list
  // of mappings.
  const void* linux_gate_loc;
  linux_gate_loc = FindBeginningOfLinuxGateSharedLibrary(pid_);

  const int fd = sys_open(maps_path, O_RDONLY, 0);
  if (fd < 0)
    return false;
  LineReader* const line_reader = new(allocator_) LineReader(fd);

  const char* line;
  unsigned line_len;
  while (line_reader->GetNextLine(&line, &line_len)) {
    uintptr_t start_addr, end_addr, offset;

    const char* i1 = my_read_hex_ptr(&start_addr, line);
    if (*i1 == '-') {
      const char* i2 = my_read_hex_ptr(&end_addr, i1 + 1);
      if (*i2 == ' ') {
        const char* i3 = my_read_hex_ptr(&offset, i2 + 6 /* skip ' rwxp ' */);
        if (*i3 == ' ') {
          MappingInfo* const module = new(allocator_) MappingInfo;
          memset(module, 0, sizeof(MappingInfo));
          module->start_addr = start_addr;
          module->size = end_addr - start_addr;
          module->offset = offset;
          const char* name = NULL;
          // Only copy name if the name is a valid path name, or if
          // we've found the VDSO image
          if ((name = my_strchr(line, '/')) != NULL) {
            const unsigned l = my_strlen(name);
            if (l < sizeof(module->name))
              memcpy(module->name, name, l);
          } else if (linux_gate_loc &&
                     reinterpret_cast<void*>(module->start_addr) ==
                     linux_gate_loc) {
            memcpy(module->name,
                   kLinuxGateLibraryName,
                   my_strlen(kLinuxGateLibraryName));
            module->offset = 0;
          }
          result->push_back(module);
        }
      }
    }
    line_reader->PopLine(line_len);
  }

  sys_close(fd);

  return result->size() > 0;
}

bool LinuxDumper::LoadCoreFile() {
  assert(core_path_);
  off_t size;
  if (!MmapAndValidateCoreFile(core_path_, &core_buffer_, &size)) {
    return false;
  }

  core_.Set(core_buffer_, size);
  const Ehdr* header = reinterpret_cast<const Ehdr*>(
      core_.GetObject(0, sizeof(Ehdr)));
  const Phdr* note = NULL;
  // Find PT_NOTES information.
  for (int i = 0; i < header->e_phnum; ++i) {
    const Phdr* program = reinterpret_cast<const Phdr*>(
        core_.GetArrayElement(header->e_phoff,
                              header->e_phentsize, i));
    if (program->p_type == PT_NOTE) {
      note = program;
      break;
    }
  }

  if (!note) {
    return false;
  }

  bool was_last_pid = false;
  static int last_pid = 0;
  MMappedRange contents = core_.Subrange(note->p_offset, note->p_filesz);
  for (u_int32_t offset = 0; offset < note->p_filesz;) {
    const Nhdr* nhdr = reinterpret_cast<const Nhdr*>(
        contents.GetObject(offset, sizeof(Nhdr)));
    const char* name = reinterpret_cast<const char*>(
        contents.GetObject(offset + sizeof(Nhdr), nhdr->n_namesz));
    int desc_offset = WordUp(sizeof(Nhdr) + nhdr->n_namesz);
    const void* desc = reinterpret_cast<const void*>(
        contents.GetObject(offset + desc_offset, nhdr->n_descsz));
    if (nhdr == NULL || name == NULL || desc == NULL) {
      fprintf(stderr, "Problem reading PT_NOTE.\n");
      return false;
    }
    switch(nhdr->n_type) {
      case NT_PRSTATUS: {
        const elf_prstatus* status =
            reinterpret_cast<const elf_prstatus*>(desc);
        pid_t pid = status->pr_pid;
        ThreadInfo thread;
        memset(&thread, 0, sizeof(ThreadInfo));
        thread.tgid = status->pr_pgrp;
        thread.ppid = status->pr_ppid;
        memcpy(&thread.regs, status->pr_reg, sizeof(thread.regs));
        core_thread_map_.insert(std::pair<pid_t, ThreadInfo>(pid, thread));
        if (!was_last_pid) {
          core_exception_information_.crashing_pid = pid;
          core_exception_information_.crashing_signal =
              status->pr_info.si_signo;
        }
        was_last_pid = true;
        last_pid = pid;
        threads_.push_back(pid);
        break;
      }
#if defined(__i386__)
      case NT_FPREGSET: {
        ThreadIterator thread = core_thread_map_.find(last_pid);
        if (was_last_pid &&
            thread != core_thread_map_.end()) {
          if (nhdr->n_descsz != sizeof(thread->second.fpregs)) {
            fprintf(stderr, "NT_FPREGSET descriptor of unexpected size\n");
          } else {
            memcpy(&thread->second.fpregs, desc,
                   sizeof(thread->second.fpregs));
          }
        }
        break;
      }
      case NT_PRXFPREG: {
        ThreadIterator thread = core_thread_map_.find(last_pid);
        if (was_last_pid && thread != core_thread_map_.end()) {
          if (nhdr->n_descsz != sizeof(thread->second.fpxregs)) {
            fprintf(stderr, "NT_PRXFPREG descriptor of unexpected size\n");
          } else {
            memcpy(&thread->second.fpxregs, desc,
                   sizeof(thread->second.fpxregs));
          }
        }
        break;
      }
#endif
    }
    offset += WordUp(desc_offset + nhdr->n_descsz);
  }

  return true;
}

// Parse /proc/$pid/task to list all the threads of the process identified by
// pid.
bool LinuxDumper::EnumerateThreads(wasteful_vector<pid_t>* result) const {
  if (IsPostMortem()) {
    // Threads are enumerated as part of loading the core file.
    return true;
  }
  char task_path[80];
  BuildProcPath(task_path, pid_, "task");

  const int fd = sys_open(task_path, O_RDONLY | O_DIRECTORY, 0);
  if (fd < 0)
    return false;
  DirectoryReader* dir_reader = new(allocator_) DirectoryReader(fd);

  // The directory may contain duplicate entries which we filter by assuming
  // that they are consecutive.
  int last_tid = -1;
  const char* dent_name;
  while (dir_reader->GetNextEntry(&dent_name)) {
    if (my_strcmp(dent_name, ".") &&
        my_strcmp(dent_name, "..")) {
      int tid = 0;
      if (my_strtoui(&tid, dent_name) &&
          last_tid != tid) {
        last_tid = tid;
        result->push_back(tid);
      }
    }
    dir_reader->PopEntry();
  }

  sys_close(fd);
  return true;
}

// Read thread info from /proc/$pid/status.
// Fill out the |tgid|, |ppid| and |pid| members of |info|. If unavailable,
// these members are set to -1. Returns true iff all three members are
// available.
bool LinuxDumper::ThreadInfoGetUsingPtrace(pid_t tid, ThreadInfo* info) {
  assert(info != NULL);
  char status_path[NAME_MAX];
  BuildProcPath(status_path, tid, "status");

  const int fd = open(status_path, O_RDONLY);
  if (fd < 0)
    return false;

  LineReader* const line_reader = new(allocator_) LineReader(fd);
  const char* line;
  unsigned line_len;

  info->ppid = info->tgid = -1;

  while (line_reader->GetNextLine(&line, &line_len)) {
    if (my_strncmp("Tgid:\t", line, 6) == 0) {
      my_strtoui(&info->tgid, line + 6);
    } else if (my_strncmp("PPid:\t", line, 6) == 0) {
      my_strtoui(&info->ppid, line + 6);
    }

    line_reader->PopLine(line_len);
  }

  if (info->ppid == -1 || info->tgid == -1)
    return false;

  if (sys_ptrace(PTRACE_GETREGS, tid, NULL, &info->regs) == -1 ||
      sys_ptrace(PTRACE_GETFPREGS, tid, NULL, &info->fpregs) == -1) {
    return false;
  }

#if defined(__i386)
  if (sys_ptrace(PTRACE_GETFPXREGS, tid, NULL, &info->fpxregs) == -1)
    return false;
#endif

#if defined(__i386) || defined(__x86_64)
  for (unsigned i = 0; i < ThreadInfo::kNumDebugRegisters; ++i) {
    if (sys_ptrace(
        PTRACE_PEEKUSER, tid,
        reinterpret_cast<void*> (offsetof(struct user,
                                          u_debugreg[0]) + i *
                                 sizeof(debugreg_t)),
        &info->dregs[i]) == -1) {
      return false;
    }
  }
#endif
  return true;
}

bool LinuxDumper::ThreadInfoGet(pid_t tid, ThreadInfo* info) {
  if (IsPostMortem()) {
    ThreadIterator i = core_thread_map_.find(tid);
    if (i == core_thread_map_.end()) {
      return false;
    }
    *info = i->second;
  } else {
    if (!ThreadInfoGetUsingPtrace(tid, info)) {
      return false;
    }
  }

  const uint8_t* stack_pointer;
#if defined(__i386)
  memcpy(&stack_pointer, &info->regs.esp, sizeof(info->regs.esp));
#elif defined(__x86_64)
  memcpy(&stack_pointer, &info->regs.rsp, sizeof(info->regs.rsp));
#elif defined(__ARM_EABI__)
  memcpy(&stack_pointer, &info->regs.uregs[R13], sizeof(info->regs.uregs[R13]));
#else
#error "This code hasn't been ported to your platform yet."
#endif

  if (!GetStackInfo(&info->stack, &info->stack_len,
                    (uintptr_t) stack_pointer))
    return false;

  return true;
}

// Get information about the stack, given the stack pointer. We don't try to
// walk the stack since we might not have all the information needed to do
// unwind. So we just grab, up to, 32k of stack.
bool LinuxDumper::GetStackInfo(const void** stack, size_t* stack_len,
                               uintptr_t int_stack_pointer) {
  // Move the stack pointer to the bottom of the page that it's in.
  const uintptr_t page_size = getpagesize();

  uint8_t* const stack_pointer =
      reinterpret_cast<uint8_t*>(int_stack_pointer & ~(page_size - 1));

  // The number of bytes of stack which we try to capture.
  static ptrdiff_t kStackToCapture = 32 * 1024;

  const MappingInfo* mapping = FindMapping(stack_pointer);
  if (!mapping)
    return false;
  const ptrdiff_t offset = stack_pointer - (uint8_t*) mapping->start_addr;
  const ptrdiff_t distance_to_end =
      static_cast<ptrdiff_t>(mapping->size) - offset;
  *stack_len = distance_to_end > kStackToCapture ?
      kStackToCapture : distance_to_end;
  *stack = stack_pointer;
  return true;
}

void LinuxDumper::CopyFromCore(void* dest, pid_t child, const void* src,
                               size_t length) {
  const Ehdr* header = reinterpret_cast<const Ehdr*>(
      core_.GetObject(0, sizeof(Ehdr)));
  const char* src_bytes = reinterpret_cast<const char*>(src);

  // Find PT_NOTES information.
  for (int i = 0; i < header->e_phnum; ++i) {
    const Phdr* program =
        (const Phdr*)core_.GetArrayElement(header->e_phoff,
                                           header->e_phentsize, i);
    const char* segment_bytes = reinterpret_cast<const char*>(program->p_vaddr);
    if (program->p_type != PT_LOAD)
      continue;

    size_t offset_in_segment = src_bytes - segment_bytes;
    const char* mapped_memory =
        reinterpret_cast<const char*>(
            core_.GetObject(program->p_offset + offset_in_segment, length));

    if (segment_bytes < src_bytes &&
        offset_in_segment < program->p_filesz &&
        mapped_memory != NULL) {
      memcpy(dest, mapped_memory, length);
      return;
    }
  }
  // Not found, fill with marker characters.
  memset(dest, 0xab, length);
}

// static
void LinuxDumper::CopyFromProcess(void* dest, pid_t child, const void* src,
                                  size_t length) {
  if (IsPostMortem()) {
    CopyFromCore(dest, child, src, length);
    return;
  }
  unsigned long tmp = 55;
  size_t done = 0;
  static const size_t word_size = sizeof(tmp);
  uint8_t* const local = (uint8_t*) dest;
  uint8_t* const remote = (uint8_t*) src;

  while (done < length) {
    const size_t l = length - done > word_size ? word_size : length - done;
    if (sys_ptrace(PTRACE_PEEKDATA, child, remote + done, &tmp) == -1) {
      tmp = 0;
    }
    memcpy(local + done, &tmp, l);
    done += l;
  }
}

// Find the mapping which the given memory address falls in.
const MappingInfo* LinuxDumper::FindMapping(const void* address) const {
  const uintptr_t addr = (uintptr_t) address;

  for (size_t i = 0; i < mappings_.size(); ++i) {
    const uintptr_t start = static_cast<uintptr_t>(mappings_[i]->start_addr);
    if (addr >= start && addr - start < mappings_[i]->size)
      return mappings_[i];
  }

  return NULL;
}

}  // namespace google_breakpad
