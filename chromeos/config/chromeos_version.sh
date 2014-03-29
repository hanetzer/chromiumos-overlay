#!/bin/sh

# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# ChromeOS version information
#
# This file is usually sourced by other build scripts, but can be run
# directly to see what it would do.

#############################################################################
# SET VERSION NUMBERS
#############################################################################
if [ -z "${FLAGS_version}" ]; then
  # Release Build number.
  # Increment by 1 for every release build.
  export CHROMEOS_BUILD=5705

  # Release Branch number.
  # Increment by 1 for every release build on a branch.
  # Reset to 0 when increasing release build number.
  export CHROMEOS_BRANCH=0

  # Patch number.
  # Increment by 1 in case a non-scheduled branch release build is necessary.
  # Reset to 0 when increasing branch number.
  export CHROMEOS_PATCH=0

  # Official builds must set CHROMEOS_OFFICIAL=1.
  if [ ${CHROMEOS_OFFICIAL:-0} -ne 1 ]; then
    # For developer builds, overwrite CHROMEOS_VERSION_PATCH with a date string
    # for use by auto-updater.
    export CHROMEOS_PATCH=$(date +%Y_%m_%d_%H%M)
  fi

  # Version string. Not indentied to appease bash.
  export CHROMEOS_VERSION_STRING=\
"${CHROMEOS_BUILD}.${CHROMEOS_BRANCH}.${CHROMEOS_PATCH}"
else
  export CHROMEOS_BUILD=$(echo ${FLAGS_version} | cut -f 1 -d ".")
  export CHROMEOS_BRANCH=$(echo ${FLAGS_version} | cut -f 2 -d ".")
  export CHROMEOS_PATCH=$(echo ${FLAGS_version} | cut -f 3 -d ".")
  export CHROMEOS_VERSION_STRING="${FLAGS_version}"
fi

# Major version for Chrome.
export CHROME_BRANCH=35
# Set CHROME values (Used for releases) to pass to chromeos-chrome-bin ebuild
# URL to chrome archive
export CHROME_BASE=
# export CHROME_VERSION from incoming value or NULL and let ebuild default
export CHROME_VERSION="$CHROME_VERSION"

# Print (and remember) version info.
echo "ChromeOS version information:"
env | egrep '^CHROMEOS_VERSION|CHROME_' | sed 's/^/    /'
