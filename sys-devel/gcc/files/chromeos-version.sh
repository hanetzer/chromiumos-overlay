#!/bin/bash
#
# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script is given one argument: the base of the source directory of
# the package, and it prints a string on stdout with the numerical version
# number for said repo.
#
# The reason we extract the version from the ChangeLog instead of BASE-VER is
# because BASE-VER contains a custom google string that lacks the x.y.z info.

#
# If we are using the AOSP repository, we will need to go down one level.
# There are multiple gcc-* subdirectories, so we pick the highest version
# gcc here (similar to the logic used in the gcc ebuild file).
gccsub=$(find "$1" -maxdepth 1 -type d -name "gcc-*" | sort -r | head -1)
if [[ -d "${gccsub}" ]] ; then
  gccdir=${gccsub}
else
  gccdir=$1
fi

exec awk '$1 == "*" && $2 == "GCC" && $4 == "released." { print $3; exit }' \
  "${gccdir}"/ChangeLog
