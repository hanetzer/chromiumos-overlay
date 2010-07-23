// Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <elf.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>

#include <cstdio>

#include "common/linux/mmapped_range.h"
#include "tools/linux/core2md/core_reader.h"

bool MmapAndValidateCoreFile(const char* filepath,
                             void** bytes,
                             off_t* size) {
  const int fd = open(filepath, O_RDONLY);
  if (fd < 0) {
    fprintf(stderr, "Could not open %s\n", filepath);
    return false;
  }

  struct stat st;
  fstat(fd, &st);

  *bytes = mmap(NULL, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
  close(fd);
  if (*bytes == MAP_FAILED) {
    perror("Failed to mmap core file");
    return false;
  }
  *size = st.st_size;

  MMappedRange core(*bytes, *size);

  const Ehdr* header =
      (const Ehdr*)core.GetObject(0, sizeof(Ehdr));

  if (header->e_ident[0] != ELFMAG0 ||
      header->e_ident[1] != ELFMAG1 ||
      header->e_ident[2] != ELFMAG2 ||
      header->e_ident[3] != ELFMAG3) {
    fprintf(stderr, "Not an ELF file.\n");
    return false;
  }

  if (header->e_ident[4] != ELF_CLASS) {
    fprintf(stderr, "32/64b mismatch.\n");
    return false;
  }

  if (header->e_version != EV_CURRENT) {
    fprintf(stderr, "Unsupported ELF version.\n");
    return false;
  }

  if (header->e_type != ET_CORE) {
    fprintf(stderr, "ELF file not a core file.\n");
    return false;
  }

  return true;
}
