// Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Provide helper function and definitions to simplify reading core files.

#ifndef _TOOLS_LINUX_CORE2MD_CORE_READER_H
#define _TOOLS_LINUX_CORE2MD_CORE_READER_H

#include <sys/types.h>  // for off_t

#if __WORDSIZE == 64
  #define ELF_CLASS ELFCLASS64
  #define Ehdr      Elf64_Ehdr
  #define Phdr      Elf64_Phdr
  #define Shdr      Elf64_Shdr
  #define Nhdr      Elf64_Nhdr
  #define auxv_t    Elf64_auxv_t
  #define WordUp(_a) (((_a) + 7) & ~7)
  typedef u_int64_t AddressType;
#else
  #define ELF_CLASS ELFCLASS32
  #define Ehdr      Elf32_Ehdr
  #define Phdr      Elf32_Phdr
  #define Shdr      Elf32_Shdr
  #define Nhdr      Elf32_Nhdr
  #define auxv_t    Elf32_auxv_t
  #define WordUp(_a) (((_a) + 3) & ~3)
  typedef u_int32_t AddressType;
#endif

#if defined(__x86_64__)
  #define ELF_ARCH  EM_X86_64
#elif defined(__i386__)
  #define ELF_ARCH  EM_386
#elif defined(__ARM_ARCH_3__)
  #define ELF_ARCH  EM_ARM
#elif defined(__mips__)
  #define ELF_ARCH  EM_MIPS
#endif

// elf_prstatus::pr_reg is an array of elf_greg_t types which happens
// to exactly alias the user_regs_struct which has nice mnemonics for the
// register numbers.
#define GET_REG_OFFSET(_name)  \
  (offsetof(user_regs_struct,_name) / sizeof(elf_greg_t))

// mmaps a core file and validates that it is a core file for this
// architecture.
bool MmapAndValidateCoreFile(const char* filepath,
                             void** bytes,
                             off_t* size);

#endif  // _TOOLS_LINUX_CORE2MD_CORE_READER_H
