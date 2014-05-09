# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
import ast
import os
import subprocess
import sys


def GetAllDeps(chrome_root):
  run_measurement = os.path.join(
      chrome_root, 'src/tools/perf/run_measurement')
  if not os.path.exists(run_measurement):
    raise IOError('run_measurement script does not exist.')
  print_bootstrap = subprocess.Popen([run_measurement,
                                      '--print-bootstrap-deps-cros'],
                                     stdout=subprocess.PIPE)
  # STDOUT will have the deps list.
  deps_list = print_bootstrap.communicate()[0]
  deps_list = ast.literal_eval(deps_list)
  # Remove the 'src/' at the front of each dep.
  return [dep.split('src/', 1)[1] for dep in deps_list]


def MakeFilterPathPrefixes(filter_prefix_list):
  def filter_path_prefixes(dep):
    """Remove unneeded folders from the deps_list"""
    for folder in filter_prefix_list:
      if dep.startswith(folder):
        return False

    return True
  return filter_path_prefixes


def main():
  """
  This script is responsible for generating the list of telemetry deps required
  to run telemetry in the autotest lab. It will print out the list of folders
  in the chrome source required to be packaged by the chromeos-chrome ebuild.

  USAGE: python get_telemetry_deps CHROME_ROOT_FOLDER [LIST OF FOLDERS TO SKIP]
  """
  if len(sys.argv) < 2:
    # Requires atleast chrome root to be passed in.
    return
  chrome_root = sys.argv[1]
  try:
    deps_list = GetAllDeps(chrome_root)
  except (IOError, subprocess.CalledProcessError):
    print ''
    return
  # Filter out any unneeded deps before returning.
  filter_path_prefixes = MakeFilterPathPrefixes(sys.argv[2:])
  deps_list = filter(filter_path_prefixes, deps_list)
  print ' '.join(deps_list)


if __name__ == '__main__':
  main()
