#!/bin/sh
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script is run in the factory process, which sets the board id and
# flags properly for cr50.

UPDATER="/usr/sbin/usb_updater"

# The return codes for different failure reasons.
ERR_GENERAL=1
ERR_ALREADY_SET=2
ERR_ALREADY_SET_DIFFERENT=3

die_as() {
  local exit_value="$1"
  shift
  echo "ERROR: $*"
  exit "${exit_value}"
}

die() {
  die_as "${ERR_GENERAL}" "$*"
}

char_to_hex() {
  printf '%s' "$1" | od -A n -t x1 | sed 's/ //g'
}

hex_eq() {
  [ $(printf '%d' "$1") = $(printf '%d' "$2") ]
}

cr50_check_board_id_and_flag() {
  local new_board_id="$(char_to_hex $1)"
  local new_flag="$2"

  local output="$("${UPDATER}" -s -i)"
  if [ $? != 0 ]; then
    die "Failed to execute ${UPDATER} -s -i"
  fi

  # Parse the output. E.g., 5a5a4146:a5a5beb9:0000ff00
  output="${output##* }"

  if [ "${output}" = "ffffffff:ffffffff:ffffffff" ]; then
    # Board ID is cleaered, it's ok to go ahead and set it.
    return 0
  fi

  # Check if the board ID has been set differently.
  # The first field is the board ID in hex. E.g., 5a5a4146
  local board_id="${output%%:*}"
  if [ "${board_id}" != "${new_board_id}" ]; then
    die_as "${ERR_ALREADY_SET_DIFFERENT}" "Board ID has been set differently."
  fi

  # Check if the flag has been set differently
  # The last field is the flag in hex. E.g., 0000ff00
  local flag=0x"${output##*:}"
  if ! hex_eq "${flag}" "${new_flag}"; then
    die_as "${ERR_ALREADY_SET_DIFFERENT}" "Flag has been set differently."
  fi

  die_as "${ERR_ALREADY_SET}" "Board ID and flag have already been set."
}

cr50_set_board_id_and_flag() {
  local board_id="$1"
  local flag="$2"

  local updater_arg="${board_id}:${flag}"
  "${UPDATER}" -s -i "${updater_arg}" 2>&1
  if [ $? != 0 ]; then
    die "Failed to update with ${updater_arg}"
  fi
}

main() {
  local phase=""
  local rlz=""

  case "$#" in
    1)
      phase="$1"

      # To provision board ID, we use RLZ brand code which is a four letter code
      # (see full list on go/crosrlz) from VPD or hardware straps, and can be
      # retrieved by command 'mosys platform brand'.
      rlz="$(mosys platform brand)"
      if [ $? != 0 ]; then
        die "Failed at 'mosys' command."
      fi

      ;;
    2)
      phase="$1"
      rlz="$2"
      ;;
    *)
      die "Usage: $0 phase [board_id]"
  esac

  case "${#rlz}" in
    0)
      die "No RLZ brand code assigned yet."
      ;;
    4)
      # Valid RLZ are 4 letters
      ;;
    *)
      die "Invalid RLZ brand code (${rlz})."
      ;;
  esac

  local flag=""
  case "${phase}" in
    "unknown")
      flag="0xff00"
      ;;
    "dev" | "proto"* | "evt"* | "dvt"*)
      flag="0xff7f"
      ;;
    "mp"* | "pvt"*)
      flag="0x7f80"
      ;;
    *)
      die "Unknown phase (${phase})"
      ;;
  esac

  cr50_check_board_id_and_flag "${rlz}" "${flag}"

  cr50_set_board_id_and_flag "${rlz}" "${flag}"
  echo "Successfully updated board ID to '${rlz}' with phase '${phase}'."
}

main "$@"
