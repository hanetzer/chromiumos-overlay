#!/bin/sh
#
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

TPM_FIRMWARE_UPDATE_LOCATION="/run/tpm_firmware_update_location"

main() {
  local tpm_version_info="$(tpm-manager get_version_info)"
  local ifx_upgrade_info="$(tpm-manager get_ifx_field_upgrade_info)"

  # Write to temp file and move so the correct state appears atomically.
  if tpm-firmware-locate-update "${tpm_version_info}" "${ifx_upgrade_info}" \
                                > "${TPM_FIRMWARE_UPDATE_LOCATION}.tmp"; then
    mv "${TPM_FIRMWARE_UPDATE_LOCATION}.tmp" "${TPM_FIRMWARE_UPDATE_LOCATION}"
  fi
}

main "$@"
