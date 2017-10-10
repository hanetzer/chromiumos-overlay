#!/bin/sh
#
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

# Status codes defined by tpm-firmware-updater.
EXIT_CODE_SUCCESS=0
EXIT_CODE_ERROR=1
EXIT_CODE_NO_UPDATE=3
EXIT_CODE_UPDATE_FAILED=4
EXIT_CODE_LOW_BATTERY=5
EXIT_CODE_NOT_UPDATABLE=6
EXIT_CODE_MISSING_APPROVAL=7
EXIT_CODE_SUCCESS_COLD_REBOOT=8

# Minimum battery charge level at which to retry running the updater.
MIN_BATTERY_CHARGE_PERCENT=10

# Directory containing tpm firmware images and behavior flags.
TPM_FIRMWARE_DIR=/lib/firmware/tpm

# Executes the updater, collects its status and prints the status to stdout.
run_updater() {
  (
    set +e
    echo "$(date -Iseconds) starting" 1>&2
    # TODO(mnissler): Add appropriate -u and -g flags once /dev/tpm0 no longer
    # requires root.
    # TODO(mnissler): Reading the VPD from flash requires CAP_SYS_ADMIN and
    # CAP_SYS_RAWIO. Figure out whether there's a way around that.
    TPM_FIRMWARE_UPDATE_MIN_BATTERY="${MIN_BATTERY_CHARGE_PERCENT}" \
      /sbin/minijail0 -c 0x220000 --ambient -e -l -n -p -r -v --uts -- \
      /bin/sh -x /usr/sbin/tpm-firmware-updater
    status=$?
    echo "$(date -Iseconds) finished with status ${status}" 1>&2
    echo "${status}" > /run/tpm-firmware-updater.status
  ) 2>>/var/log/tpm-firmware-updater.log | (
    # The updater writes progress indication in percent line-wise to stdout.
    # Wait for the first progress update before showing the message since we
    # don't want to show the message if there is no update.
    if read progress; then
      chromeos-boot-alert update_tpm_firmware
      while true; do
        chromeos-boot-alert update_progress "${progress}"
        read progress || break
      done
    fi
  ) >/dev/null

  # Read and return the updater status code. Leave the file around so the
  # send-tpm-firmware-update-metrics job can pick it up later for inclusion in
  # metrics.
  local status="$(cat /run/tpm-firmware-updater.status)"
  echo "${status:-1}"
}

# Updates a value in the vpd_params string.
update_vpd_params() {
  local params=$1
  local key=$2
  local value=$3

  local stripped="$(printf "${params}" | tr ',' '\n' | grep -v "^${key}:")"
  printf "${key}:${value}\n${stripped}" | tr '\n' ','
}

wait_for_battery_to_charge() {
  local displayed_message

  while true; do
    # Recheck whether charge level is sufficient.
    local power_status="$(dump_power_status)"
    local battery_charge=$(echo "${power_status}" |
                           grep "^battery_display_percent " |
                           cut -d ' ' -f 2)
    if [ "${battery_charge%%.*}" -ge "${MIN_BATTERY_CHARGE_PERCENT}" ]; then
      break
    fi

    # Decide which message to show.
    local message
    if echo "${power_status}" | grep -Fqx "line_power_connected 1"; then
      message=update_tpm_firmware_low_battery_charging
    else
      message=update_tpm_firmware_low_battery
    fi

    # Only update the message if it changes to avoid flashing the screen.
    if [ "${message}" != "${displayed_message}" ]; then
      chromeos-boot-alert "${message}"
      displayed_message="${message}"
    fi

    sleep 1
  done
}

# Reboot and wait to guarantee that we don't proceed further until reboot
# actually happens.
reboot_here() {
  local reboot_type="$1"
  if [ "${reboot_type}" = "cold" ]; then
    # Try to request auto-booting after shutting down, but don't abort if it
    # doesn't work. Worst case, the user will need to manually press Power to
    # boot.
    ectool reboot_ec cold at-shutdown || :
    shutdown -h now
  else
    reboot
  fi
  sleep 1d
  exit 1
}

# Run the updater in a loop so we can perform retries in case of insufficient
# battery charge.
while true; do
  local status="$(run_updater)"
  case "${status}" in
    ${EXIT_CODE_SUCCESS})
      reboot_here "warm"
      ;;
    ${EXIT_CODE_SUCCESS_COLD_REBOOT})
      reboot_here "cold"
      ;;
    ${EXIT_CODE_ERROR}|${EXIT_CODE_NO_UPDATE})
      # It's OK to continue booting.
      ;;
    ${EXIT_CODE_UPDATE_FAILED})
      # Clear upgrade approval as a precautionary measure. This helps to avoid
      # boot loops in case of systematic bugs causing the firmware updater to
      # bail out before actually starting the update.
      local vpd_params="$(vpd -i RW_VPD -g "tpm_firmware_update_params")"
      vpd_params="$(update_vpd_params "${vpd_params}" 'mode' 'failed')"
      vpd -i RW_VPD -s "tpm_firmware_update_params=${vpd_params}"

      # The TPM is likely to be in an inoperational state due to the failed
      # update. If it is, we need to go through recovery anyways to retry the
      # update. Show a message to the user telling them about the failed update
      # and reboot so the firmware can determine whether recovery is necessary.
      chromeos-boot-alert update_tpm_firmware_failure
      reboot_here "warm"
      ;;
    ${EXIT_CODE_LOW_BATTERY})
      # Show a notification while we wait for the battery to charge.
      wait_for_battery_to_charge
      continue
      ;;
    ${EXIT_CODE_NOT_UPDATABLE}|${EXIT_CODE_MISSING_APPROVAL})
      # We have an update, but either the TPM is already owned, or the update
      # wasn't approved by the user. Drop a flag file so the system can detect
      # this situation and allow the user to trigger the update flow.
      touch "/run/tpm_firmware_update_available"
      ;;
    *)
      # When we see an undefined status code, we continue booting. That's
      # somewhat risky, but likely indicates a bug in the firmware updater
      # driver script before it got to the point of actually attempting an
      # update, so we should be good. The alternative would be to inhibit
      # further firmware updates by updating VPD and rebooting.
      ;;
  esac

  # Fall through means "continue booting".
  exit 0
done
