#!/usr/bin/env python2
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Parse log files containing clang-tidy warnings, and generate reports."""

from __future__ import print_function

import os
import sys

import clang_tidy_execute

def usage_error(err_msg):
  print(err_msg)
  print('Usage:  clang-tidy-parse-build-log.py <build_log>')
  sys.exit(1)

def Main(args):
  if len(args) != 1:
    usage_error('Wrong number of args!')

  cwd = os.path.dirname(os.path.realpath(__file__))
  warn_script = os.path.join(cwd, 'clang-tidy-warn.py')

  logfile = args[0]
  if not os.path.exists(logfile):
    usage_error('Cannot find log file "%s"' % logfile)

  if not os.path.exists(warn_script):
    usage_error('Cannot find %s' % warn_script)

  warnfile = 'warnings.html'
  warnfile_csv = 'warnings.csv'

  result = clang_tidy_execute.Execute('python %s %s ' % (
      warn_script, logfile) +
      '--csvpath %s --url http://cs/android --separator "?l=" > %s' %
      (warnfile_csv, warnfile))

  # Handle if we are running on an older version of warn.py
  # that does not have support for --csvpath added in
  # aosp/369755
  if result.returncode == 2:
    result = clang_tidy_execute.Execute('python %s %s ' % (
        warn_script, logfile) +
        '--url http://cs/android --separator "?l=" > %s' %
        warnfile)

  if result.returncode != 0:
    print("Couldn't generate warnings.html")
    try:
      os.remove(warnfile)
    except EnvironmentError:
      pass
    try:
      os.remove(warnfile_csv)
    except EnvironmentError:
      pass

  return 0

if __name__ == "__main__":
  sys.exit(Main(sys.argv[1:]))
