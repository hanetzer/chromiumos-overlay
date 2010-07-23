// Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Utility to dump the contents of a Linux ELF core dump file,
// specifically showing register sets, exception causes, and stacks ->
// phdr mappings.

#include <elf.h>
#include <sys/procfs.h>  // for elf_prstatus and elf_prpsinfo
#include <unistd.h>

#include <cstdio>
#include <list>

#include "common/linux/mmapped_range.h"
#include "google_breakpad/common/minidump_cpu_x86.h"
#include "google_breakpad/common/minidump_format.h"
#include "tools/linux/core2md/core_reader.h"

static int usage(const char* argv0) {
  fprintf(stderr, "Usage: %s <core file>\n", argv0);
  return 1;
}

struct thread_stack_pointer {
  int pid;
  AddressType stack_pointer;
};

static void DumpNotesAndStoreThreadStacks(
    const MMappedRange& contents,
    const Phdr* header,
    std::list<thread_stack_pointer> *thread_sp_list) {
  for (u_int32_t offset = 0; offset < header->p_filesz;) {
    const Nhdr* nhdr = reinterpret_cast<const Nhdr*>(
        contents.GetObject(offset, sizeof(Nhdr)));
    const char* name = reinterpret_cast<const char*>(
        contents.GetObject(offset + sizeof(Nhdr), nhdr->n_namesz));
    printf("  Note: %.*s, type %d\n", nhdr->n_namesz, name, nhdr->n_type);
    int desc_offset = WordUp(sizeof(Nhdr) + nhdr->n_namesz);
    const void* desc = reinterpret_cast<const void*>(
        contents.GetObject(offset + desc_offset, nhdr->n_descsz));
    switch(nhdr->n_type) {
      case NT_PRPSINFO: {
        const elf_prpsinfo* info = reinterpret_cast<const elf_prpsinfo*>(desc);
        printf("    prpsinfo: pid %d, state %c, %.16s / %.80s\n",
               info->pr_pid, info->pr_state, info->pr_fname, info->pr_psargs);
        break;
      }
      case NT_AUXV:
        printf("    auxv: offset %d, size %x\n", desc_offset, nhdr->n_descsz);
        break;
      case NT_PRSTATUS: {
        const elf_prstatus* status =
            reinterpret_cast<const elf_prstatus*>(desc);
        printf("    prstatus: "
               "signo: %d, "
               "code: %d, "
               "errno: %d, "
               "currsig: %d, "
               "pending sigs: %lu, "
               "pid %d\n",
               status->pr_info.si_signo,
               status->pr_info.si_code,
               status->pr_info.si_errno,
               status->pr_cursig,
               status->pr_sigpend,
               status->pr_pid);
#if defined(__i386__)
        printf("      esp %lx\n", status->pr_reg[GET_REG_OFFSET(esp)]);
        thread_stack_pointer this_stack = {
          status->pr_pid,
          status->pr_reg[GET_REG_OFFSET(esp)],
        };
        thread_sp_list->push_back(this_stack);
#endif
        break;
      }
      case NT_FPREGSET: {
        printf("    fpregset:\n");
#if defined(__i386__)
        const user_fpregs_struct* regs =
            reinterpret_cast<const user_fpregs_struct*>(desc);
        printf("      cwd %lx\n", regs->cwd);
#endif
        break;
      }
      case NT_PRXFPREG: {
        printf("    fpxregset:\n");
#if defined(__i386__)
        const user_fpxregs_struct* regs =
            reinterpret_cast<const user_fpxregs_struct*>(desc);
        printf("      cwd %x\n", regs->cwd);
#endif
        break;
      }
    }
    offset += WordUp(desc_offset + nhdr->n_descsz);
  }
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    return usage(argv[0]);
  }

  void* buffer;
  off_t size;
  if (!MmapAndValidateCoreFile(argv[1], &buffer, &size)) {
    return usage(argv[0]);
  }

  MMappedRange core(buffer, size);
  const Ehdr* header =
      (const Ehdr*)core.GetObject(0, sizeof(Ehdr));

  std::list<thread_stack_pointer> thread_sp_list;

  // Load PT_NOTES information and show headers.
  for (int i = 0; i < header->e_phnum; ++i) {
    const Phdr* program =
        (const Phdr*)core.GetArrayElement(header->e_phoff,
                                          header->e_phentsize, i);
    printf("Program header %d: type %d, size %lx, at mem %lx, offset %lx\n",
           i,
           program->p_type,
           static_cast<unsigned long>(program->p_filesz),
           static_cast<unsigned long>(program->p_vaddr),
           static_cast<unsigned long>(program->p_offset));
    if (program->p_type == PT_NOTE) {
      DumpNotesAndStoreThreadStacks(
          core.Subrange(program->p_offset, program->p_filesz),
          program,
          &thread_sp_list);
    }
  }

  // Correlate stack pointers to program headers.
  for (int i = 0; i < header->e_phnum; ++i) {
    const Phdr* program =
        (const Phdr*)core.GetArrayElement(header->e_phoff,
                                          header->e_phentsize, i);
    std::list<thread_stack_pointer>::iterator thread_it;
    for (thread_it = thread_sp_list.begin();
         thread_it != thread_sp_list.end();
         ++thread_it) {
      if (thread_it->stack_pointer >= program->p_vaddr &&
          thread_it->stack_pointer < program->p_vaddr + program->p_filesz) {
        printf("Thread %d (stack pointer %p) has stack in program header %d\n",
               thread_it->pid,
               reinterpret_cast<void*>(thread_it->stack_pointer),
               i);
      }
    }
  }

  return 0;
}
