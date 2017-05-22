#!/bin/sh
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script is run at postinstall phase of Chrome OS installation process.
# It checks if the currently running cr50 image is ready to accept a
# background update and if the resident trunks_send utility is capable of
# updating the H1. If any of the checks fails, the script exits, otherwise it
# tries updating the H1 with the new cr50 image.

script_name="$(basename "$0")"
pid="$$"

# The mount point of the new image is passed in as the first parameter.
root="$1"

logit() {
  # TODO(vbendeb): use proper logger invocation once logger is fixed.
  logger -t "${script_name}" --id="${pid}" "$@"
}

logit "Starting"

CR50_IMAGE="${root}/opt/google/cr50/firmware/cr50.bin.prod"
if [ ! -f "${CR50_IMAGE}" ]; then
  logit "${CR50_IMAGE} not found, quitting."
  exit 1
fi

UPDATER="/usr/sbin/trunks_send"
if [ ! -x "${UPDATER}" ]; then
  logit "${UPDATER} not found, quitting."
  exit 1
fi

if ! "${UPDATER}" --help | grep -q '\--update'; then
  logit "${UPDATER} does not support cr50 updates, quitting."
  exit 1
fi

logit "using ${UPDATER} for update"

retries=0
while [ "${retries}" -ne 3 ]; do
  output="$("${UPDATER}" --update "${CR50_IMAGE}" 2>&1)"
  exit_status="$?"
  if [ "${exit_status}" -eq 0 ]; then
    logit "success"
    break
  fi
  if [ "${exit_status}" -eq 2 ]; then
    logit "Cr50 running old version, quitting"
    break
  fi

  : $(( retries += 1 ))
  logit "${UPDATER} attempt ${retries} error ${exit_status}"
  logit "${output}"

  # Need to sleep for at least a minute to get around cr50 update throttling:
  # it rejects repeat update attempts happening sooner than 60 seconds after
  # the previous one.
  sleep 70
done

exit "${exit_status}"
