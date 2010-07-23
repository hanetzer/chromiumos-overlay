// Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <elf.h>
#include <stdio.h>
#include <string.h>
#include <sys/procfs.h>  // for elf_prstatus and elf_prpsinfo
#include <unistd.h>

#include <map>

#include "tools/linux/core2md/minidump_writer.h"

static int ShowUsage(const char* argv0) {
  fprintf(stderr, "Usage: %s <core file> <procfs dir> <output>\n", argv0);
  return 1;
}

int main(int argc, char *argv[]) {
  if (argc != 4) {
    return ShowUsage(argv[0]);
  }

  if (!google_breakpad::WriteMinidumpFromCore(argv[3],
                                              argv[1],
                                              argv[2])) {
    fprintf(stderr, "Unable to generate minidump.\n");
    return 1;
  }

  return 0;
}
