#!/bin/sh
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script is a wrapper around gsctool. It creates and displays a
# qrcode from the challenge string returned by gsctool. The cr50
# is reset when a valid authorization code is entered.

# gsctool exit code.
EXIT_CODE_ALL_UPDATED=1

# RMA Reset Authorization parameters.
# - URL of Reset Authorization Server.
RMA_SERVER="https://google.com/chromeos/cr50resetauth/request?challenge="
# - Number of retries before giving up.
MAX_RETRIES=3
# - Time in seconds to delay before generating another qrcode.
RETRY_DELAY=10

cr50_reset() {
  # Make sure frecon is running.
  local frecon_pid="$(cat /run/frecon/pid)"

  # This is the path to the pre-chroot filesystem. Since frecon is started
  # before the chroot, all files that frecon accesses must be copied to
  # this path.
  local chg_str_path="/proc/${frecon_pid}/root"

  if [ ! -d "${chg_str_path}" ]; then
    echo "frecon not running. Can't display qrcode."
    return 1
  fi

  # Make sure qrencode is installed.
  if ! command -v qrencode > /dev/null; then
    echo "qrencode is not installed."
    return 1
  fi

  # Make sure gsctool is installed.
  if ! command -v gsctool > /dev/null; then
    echo "gsctool is not installed."
    return 1
  fi

  # Get HWID and replace whitespace with underscore.
  local hwid="$(crossystem hwid 2>/dev/null | sed -e 's/ /_/g')"

  # Get challenge string and remove "Challenge:".
  local ch="$(gsctool -t -r | sed -e 's/.*://g')"

  # Test if we have a challenge.
  if [ -z "${ch}" ]; then
    echo "Challenge wasn't generated. CR50 might need updating."
    return 1
  fi

  # Display the challenge.
  echo "Challenge:"
  echo "${ch}" | awk -F' ' '{print $1, $2, $3, $4}'
  echo "${ch}" | awk -F' ' '{print $5, $6, $7, $8}'
  echo "${ch}" | awk -F' ' '{print $9, $10, $11, $12}'
  echo "${ch}" | awk -F' ' '{print $13, $14, $15, $16}'

  # Remove whitespace from challenge.
  ch="$(echo "${ch}" | sed -e 's/ //g')"

  # Calculate challenge string.
  local chstr="${RMA_SERVER}${ch}&hwid=${hwid}"

  # Create qrcode and display it.
  qrencode -o "${chg_str_path}/chg.png" "${chstr}"
  printf "\033]image:file=/chg.png\033\\" > /run/frecon/vt0

  local n=0
  local ac
  local status
  while [ ${n} -lt ${MAX_RETRIES} ]; do
    # Read authorization code.
    read -p "Enter authorization code: " ac

    # Test authorization code.
    gsctool -t -r "${$ac}"
    status=$?

    case "${status}" in
      ${EXIT_CODE_ALL_UPDATED})
        read -p "Press [ENTER] to continue"
        return 0
        ;;
      *)
        echo "Invalid authorization code. Please try again."
        echo
        ;;
    esac

    : $(( n += 1 ))
    if [ ${n} -eq ${MAX_RETRIES} ]; then
      echo "Number of retries exceeded. Another qrcode will generate in 10s."
      local m=0
      while [ ${m} -lt ${RETRY_DELAY} ]; do
        printf "."
        sleep 1
        : $(( m += 1 ))
      done
      echo
    fi
  done
}

main() {
  cr50_reset
  if [ $? -ne 0 ]; then
    echo "Cr50 Reset Error."
  fi
}

main "$@"
