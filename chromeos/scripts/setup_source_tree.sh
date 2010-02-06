#!/bin/bash

# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script sets up your source tree to build using the new build framework.
# It is meant as a stop-gap so that we can use the old stuff until we switch
# over to the new stuff without disrupting the old tree.

PORTAGE_SCRIPTS="$(dirname "$0")"
SRC_ROOT="${PORTAGE_SCRIPTS}/../../../.."
SCRIPTS="${SRC_ROOT}/scripts"
OVERLAY="${SRC_ROOT}/third_party/chromiumos-overlay"
OVERLAY_SCRIPTS_RELPATH="../third_party/chromiumos-overlay/chromeos/scripts"

if [[ ! -d "${SCRIPTS}" ]]; then
  echo "Error: Can't find scripts directory '${SCRIPTS}'"
  exit 1
fi
if [[ ! -d "${OVERLAY}" ]]; then
  echo "Error: Can't find portage directory '${PORTAGE}'"
  echo "Did you checkout the portage tree in third_party/chromiumos-overlay?"
  exit 1
fi

# Clean out any old scripts that may exist.
rm -f "${SCRIPTS}/new_make_env.sh"
rm -f "${SCRIPTS}/new_build_pkgs.sh"
rm -f "${SCRIPTS}/new_build_image.sh"
rm -f "${SCRIPTS}/new_customize_rootfs.sh"
rm -f "${SCRIPTS}/setup_board"

# Set up symlinks to the new build scripts
ln -s "${OVERLAY_SCRIPTS_RELPATH}"/make_env.sh \
  "${SCRIPTS}/new_make_env.sh"
ln -s "${OVERLAY_SCRIPTS_RELPATH}"/build_pkgs.sh \
  "${SCRIPTS}/new_build_pkgs.sh"
ln -s "${OVERLAY_SCRIPTS_RELPATH}"/build_image.sh \
  "${SCRIPTS}/new_build_image.sh"
ln -s "${OVERLAY_SCRIPTS_RELPATH}"/customize_rootfs.sh \
  "${SCRIPTS}/new_customize_rootfs.sh"
ln -s "${OVERLAY_SCRIPTS_RELPATH}"/setup_board \
  "${SCRIPTS}/setup_board"
