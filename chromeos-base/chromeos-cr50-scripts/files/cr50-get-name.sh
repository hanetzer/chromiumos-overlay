#!/bin/sh
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This helper script is sourced by init and postinstall scripts.
#

#
# cr50_get_name
#
# Find out which if the two available Cr50 images should be used. The only
# required command line parameter is the string, a command used to communicate
# with Cr50 (different invocations are used in case of init and postinstall).
#
# The output is the file name of the Cr50 image to use printed to stdout.
#
cr50_get_name() {
  local board_flags
  local cr50_image_base_name="/opt/google/cr50/firmware/cr50.bin"
  local ext="prod"  # Prod is a safer default option.
  local logger_tag="cr50_get_name"
  local updater="$1"

  logger -t "${logger_tag}" "updater is ${updater}"

  # Determine the type of the Cr50 image to use based on the H1's board ID
  # flags. The hexadecimal value of flags is reported by 'gsctool -i' in the
  # last element of a colon separated string of values.
  board_flags="0x$(${updater} -i | sed 's/.*://')"

  if [ -z "${board_flags}" ]; then
    # Any error in detecting board flags will force using the prod image,
    # which the safe option.
    logger -t  "${logger_tag}" "error detecting board ID flags"
  else
    local pre_pvt

    # Flag bit 0x10 is the indication that this is a pre-pvt device.
    pre_pvt=$(( board_flags & 0x10 ))

    if [ "${pre_pvt}" = "16" ]; then
      ext="prepvt"
    fi
  fi

  logger -t "${logger_tag}" \
    "board_flags: '${board_flags}', extension: '${ext}'"

  printf "${cr50_image_base_name}.${ext}"
}