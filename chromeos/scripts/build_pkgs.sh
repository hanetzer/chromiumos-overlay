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
DEFINE_string target "x86" \
  "The target architecture to build for. One of { x86, arm }."
DEFINE_boolean usepkg $FLAGS_TRUE \
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

# What cross-build are we targeting?
CROSS_TARGET=""
case "$FLAGS_target" in
  x86)
    CROSS_TARGET="i686-pc-linux-gnu"
    ;;
  arm)
    CROSS_TARGET="armv7a-softfloat-linux-gnueabi"
    ;;
  *)
    echo "Error: Invalid target specified: ${FLAGS_target}"
    exit 1
esac

USEPKG=""
if [[ $FLAGS_usepkg -eq $FLAGS_TRUE ]]; then
  USEPKG="--getbinpkg --usepkg"
fi

if [[ $FLAGS_jobs -ne -1 ]]; then
  EMERGE_JOBS="--jobs=$FLAGS_jobs"
fi

sudo CHROMEOS_ROOT="$SRC_ROOT/.." emerge-${CROSS_TARGET} \
  -uDNv $USEPKG chromeos-base/hard-target-depends $EMERGE_JOBS
sudo CHROMEOS_ROOT="$SRC_ROOT/.." emerge-${CROSS_TARGET} \
  -uDNv $USEPKG chromeos-base/chromeos $EMERGE_JOBS
if [[ $FLAGS_withdev -eq $FLAGS_TRUE ]]; then
  sudo CHROMEOS_ROOT="$SRC_ROOT/.." emerge-${CROSS_TARGET} \
    -uDNv $USEPKG chromeos-base/chromeos-dev $EMERGE_JOBS
fi
