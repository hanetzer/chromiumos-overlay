#! /usr/bin/python
# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Checks whether all function pointers in src/platform/cros/load.cc are
# initialized correctly.
#
# load.cc in libcros declare a function pointer using a DECL_FUNC macro like:
#   DECL_FUNC_1(EnableScreenLock, void, bool);
#   DECL_FUNC_0(RequestShutdown, void);
#   DECL_FUNC_1(GetSupportedInputMethods,
#     InputMethodDescriptors*, InputMethodStatusConnection*);
#   DECL_FUNC_1(
#     InputMethodStatusConnectionIsAlive, bool, InputMethodStatusConnection*);
#
# Then the function pointer is initialized with a return values of ::dlsym by
# INIT_FUNC as follows:
#   INIT_FUNC(EnableScreenLock);
#   INIT_FUNC(RequestShutdown);
#   INIT_FUNC(GetSupportedInputMethods);
#   INIT_FUNC(InputMethodStatusConnectionIsAlive);
#
# This script checks whether all pointers declared are initialized by INIT_FUNC
# and reports error if not. If we forget to call INIT_FUNC, run-time crash due
# to a NULL pointer dereference could happen. Please note that the script does
# not check unnecessary INIT_FUNCs since they are checked by g++.

__author__ = "yusukes"

import fileinput
import re
import sys

def main():
  functions = set()
  in_decl = False  # True when we're inside a DECL_FUNC_N macro.

  for line in fileinput.input():
    if re.match(r'\s*DECL_FUNC_[0-9]\($', line):
      # Found DECL_FUNC_N without a function name.
      in_decl = True
    else:
      match_decl = re.match(r'\s*DECL_FUNC_[0-9]\((.*?),', line)
      match_init = re.match(r'\s*INIT_FUNC\((.+)\);$', line)
      if in_decl:
        match_variable = re.match(r'\s*(.*?),', line)
        if match_variable:
          # Found a function name.
          functions.add(match_variable.group(1))
      elif match_decl:
        # Found DECL_FUNC_N with a function name.
        functions.add(match_decl.group(1))
      elif match_init and (match_init.group(1) in functions):
        # Found INIT_FUNC with a function name. Remove the function from the
        # dictionary.
        functions.remove(match_init.group(1))
      in_decl = False

  # At this point, only uninitialized functions are left in |functions|.
  if len(functions) > 0:
    for function in functions:
      print 'ERROR: INIT_FUNC for %s is missing!' % function
    sys.exit(1)
  sys.exit(0)

if __name__ == '__main__':
  main()
