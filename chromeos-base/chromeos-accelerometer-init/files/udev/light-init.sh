#!/bin/sh
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Send calibration data to light or proximity sensors.

if [ $# != 2 ]; then
  echo "Usage: $0 iio_device_name device_type"
  exit 1
fi

DEVICE=$1
TYPE=$2

: ${LIGHT_UNIT_TEST:=false}

IIO_DEVICES="/sys/bus/iio/devices"
IIO_DEVICE_PATH="${IIO_DEVICES}/${DEVICE}"

SENSOR_CALIB_TYPES="bias scale"

# Hook for unit tests: Test script redefines this function to monitor what is
# written to sysfs.
set_sysfs_entry() {
  local name="$1"
  local value="$2"

  echo "${value}" > "${name}"
}

# Function to access calibration data.
get_calibration_from_vpd() {
  local name="$1"
  vpd_get_value "${name}"
}

# Sets pre-determined calibration values for the light or proximity sensors.
# The calibration values are fetched from the VPD.
set_calibration_values() {
  local value_type name vpd_name value
  local get_fct="$1"

  for value_type in ${SENSOR_CALIB_TYPES}; do
    name="in_${TYPE}_calib${value_type}"
    case "${name}" in
      "in_illuminance_calibbias")
        vpd_name="als_cal_intercept"
        ;;
      "in_illuminance_calibscale")
        vpd_name="als_cal_slope"
        ;;
      *)
        # Not defined for proximity sensor
        continue
    esac
    value="$("${get_fct}" "${vpd_name}" "${value_type}")"
    if [ -z "${value}" ]; then
      continue
    fi

    set_sysfs_entry "${IIO_DEVICE_PATH}/${name}" "${value}"
  done
}

main() {
  set_calibration_values get_calibration_from_vpd
}

# invoke main if not in test mode, otherwise let the test code call.
if ! ${LIGHT_UNIT_TEST}; then
  main "$@"
fi
