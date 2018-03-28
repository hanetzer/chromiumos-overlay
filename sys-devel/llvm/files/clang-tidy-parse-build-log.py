#!/usr/bin/env python2
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Parse log files containing clang-tidy warnings, and generate reports."""

from __future__ import print_function

import argparse
import datetime
import os
import sys

import clang_tidy_execute

def Main(argv):
  parser = argparse.ArgumentParser()

  parser.add_argument(
      '--output_dir',
      dest='out_dir',
      default='',
      help='Directory in which to write the resulting html & csv file.')
  parser.add_argument(
      '--log_file',
      dest='log_file',
      default=None,
      required=True,
      help='File containing the clang-tidy warnings to be parsed.')

  options = parser.parse_args(argv)

  output_dir = options.out_dir if options.out_dir else '/tmp/clang-tidy-output'

  cwd = os.path.dirname(os.path.realpath(__file__))
  warn_script = os.path.join(cwd, 'clang-tidy-warn.py')

  logfile = options.log_file
  if not os.path.exists(logfile):
    parser.error('Cannot find log file "%s"' % logfile)

  if not os.path.exists(warn_script):
    parser.error('Cannot find %s' % warn_script)

  # Normally, ChromeOS build logs have a filename format like:
  # 'pkg-part1:pkg-part2:date-time.log'.  Below we parse this to find the
  # package name(s).  We use these to create the warnings file names:
  # 'date.package.warnings.html' and 'date.package.warnings.csv'.
  # If filename does not conform to ChromeOS build log format, use full
  # filename rather than the package name.

  dirname, filename = os.path.split(logfile)
  filename_bits = filename.split(':')
  timestamp = ''
  if len(filename_bits) >= 3:
    package = '%s-%s' % (filename_bits[0], filename_bits[1])
    time_parts = filename_bits[2].split('-')
    timestamp = time_parts[0]
  else:
    package = filename

  if not timestamp:
    # Get a string with the current date, in the format 'YYYYMMDD'.
    timestamp = datetime.datetime.strftime(datetime.datetime.now(), '%Y%m%d')

  html_filename = '%s.%s.warnings.html' % (timestamp, package)
  csv_filename = '%s.%s.warnings.csv' % (timestamp, package)

  # If the user did not specify a particular output directory and the logs
  # appear to be in the default input directory, which contains the board name,
  # extract the board name from the input directory and add it to the default
  # output directory name.
  if not options.out_dir:
    dirname_bits = dirname.split('/')
    if dirname[0] == '/' and dirname_bits[0] == '':
      dirname_bits = dirname_bits[1:]
    if (len(dirname_bits) == 3 and dirname_bits[0] == 'tmp' and
        dirname_bits[1] == 'clang-tidy-logs'):
      board = dirname_bits[2]
      output_dir = os.path.join (output_dir, board)

  # Create the output directory if it does not already exist.
  if not os.path.exists(output_dir):
    os.makedirs(output_dir)

  warnfile = os.path.join(output_dir, html_filename)
  warnfile_csv = os.path.join(output_dir, csv_filename)

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
