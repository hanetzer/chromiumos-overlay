#!/bin/bash

# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Script to build the set of binary packages needed by Chrome OS. It will
# cross compile all of the packages into the given targets root and build
# binary packages as a side-effect. The output packages will be picked up
# by the build_image script to put together a bootable Chrome OS image.
#
# NOTE: This script must be run from the chromeos build chroot environment.
#

# Load common constants.  This should be the first executable line.
# The path to common.sh should be relative to your script's location.
. "$(dirname "$0")/common.sh"

# Script must be run inside the chroot
assert_inside_chroot

# Flags
DEFINE_string board "" \
  "The board to build packages for."
DEFINE_boolean usepkg $FLAGS_FALSE \
  "Use binary packages to bootstrap when possible."
DEFINE_boolean withdev $FLAGS_TRUE \
  "Build useful developer friendly utilities."
DEFINE_integer jobs -1 \
  "How many packages to build in parallel at maximum."

# Parse command line
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# Die on any errors.
set -e

if [ -z "$FLAGS_board" ] ; then
  echo "Error: --board is required."
  exit 1
fi

USEPKG=""
if [[ $FLAGS_usepkg -eq $FLAGS_TRUE ]]; then
  USEPKG="--getbinpkg --usepkg"
fi

if [[ $FLAGS_jobs -ne -1 ]]; then
  EMERGE_JOBS="--jobs=$FLAGS_jobs"
fi

sudo emerge -uDNv $USEPKG world $EMERGE_JOBS
sudo emerge-${FLAGS_board} \
  -uDNv $USEPKG chromeos-base/hard-target-depends $EMERGE_JOBS
sudo emerge-${FLAGS_board} \
  -uDNv $USEPKG chromeos-base/chromeos $EMERGE_JOBS
if [[ $FLAGS_withdev -eq $FLAGS_TRUE ]]; then
  sudo emerge-${FLAGS_board} \
    -uDNv $USEPKG chromeos-base/chromeos-dev $EMERGE_JOBS
fi
