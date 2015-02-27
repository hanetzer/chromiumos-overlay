#!/usr/bin/python
# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""This script wraps the go cross compilers.

It ensures that Go binaries are linked with an external linker
by default (cross gcc). Appropriate flags are added to build a
position independent executable (PIE) for ASLR.
"export GOPIE=0" to temporarily disable this behavior.
"""

import os
import sys

# The following values are filled in by the ebuild at installation time:
GOARCH = '@GOARCH@'
CC = '@CC@'
CXX = '@CXX@'
GOTOOL = '@GOTOOL@'


def has_ldflags(argv):
  """Check if any linker flags are present in argv."""
  link_flags = set(('-ldflags', '-linkmode', '-extld', '-extldflags'))
  if set(argv) & link_flags:
    return True
  for arg in argv:
    if arg.startswith('-ldflags=') or arg.startswith('-linkmode='):
      return True
  return False


def main(argv):
  pie_enabled = os.getenv('GOPIE', '1') != '0'
  pie_flags = []

  if len(argv) and pie_enabled and not has_ldflags(argv):
    if argv[0] in ('build', 'run', 'test'):
      pie_flags = [
          argv[0],
          '-ldflags',
          '-linkmode=external -extld ' + CC + ' -extldflags "-pie"'
      ]
      argv = argv[1:]
    elif argv[0] == 'tool':
      # Handle direct linker invocations, e.g. "go tool 6l <args>".
      if len(argv) > 1 and len(argv[1]) == 2 and argv[1][1] == 'l':
        pie_flags = [
            argv[0],
            argv[1],
            '-linkmode=external',
            '-extld',
            CC,
            '-extldflags',
            '-pie'
        ]
        argv = argv[2:]

  os.environ['GOOS'] = 'linux'
  os.environ['GOARCH'] = GOARCH
  os.environ['CGO_ENABLED'] = '1'
  os.environ['CC'] = CC
  os.environ['CXX'] = CXX
  os.execv(GOTOOL, [GOTOOL] + pie_flags + argv)


if __name__ == '__main__':
  main(sys.argv[1:])
