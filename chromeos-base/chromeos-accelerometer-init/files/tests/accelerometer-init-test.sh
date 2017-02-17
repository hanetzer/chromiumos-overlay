#!/bin/bash
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Unit test for udev script udev/accelerometer-init.sh

export LC_ALL=C
ACCELEROMETER_UNIT_TEST=true

ACCEL_TEMP_TEMPLATE=test_fw.XXXXXX
ACCEL_TEMP_DIR=$(mktemp -d --tmpdir "${ACCEL_TEMP_TEMPLATE}")

TEST_DIR=$(dirname "$0")
SCRIPT_DIR="$(dirname "${TEST_DIR}")/udev"

cleanup() {
  local rv=$?
  if [ ${rv} -eq 0 ]; then
    rm -rf "${ACCEL_TEMP_DIR}"
  else
    echo "${test_name} Failed: logs left in ${ACCEL_TEMP_DIR}"
  fi
  exit ${rv}
}

trap cleanup EXIT INT TERM

. "${SCRIPT_DIR}/accelerometer-init.sh"

declare -a mock_vpd_data
declare test_name

# Override set_sysfs_entry to store which sysfs attributes the test changes.
set_sysfs_entry() {
  echo "$1=$2" >> "${ACCEL_TEMP_DIR}/${test_name}.out"
}

# Override vpd_get_value to return mock data.
vpd_get_value() {
  case "$1" in
    "in_accel_x_base_calibbias")
       echo "${mock_vpd_data[0]}"
       ;;
    "in_accel_y_base_calibbias")
       echo "${mock_vpd_data[1]}"
       ;;
    "in_accel_z_base_calibbias")
       echo "${mock_vpd_data[2]}"
       ;;
    "in_accel_x_lid_calibbias")
       echo "${mock_vpd_data[3]}"
       ;;
    "in_accel_y_lid_calibbias")
       echo "${mock_vpd_data[4]}"
       ;;
    "in_accel_z_lid_calibbias")
       echo "${mock_vpd_data[5]}"
       ;;
    "in_anglvel_x_base_calibbias")
       echo "${mock_vpd_data[6]}"
       ;;
    "in_anglvel_y_base_calibbias")
       echo "${mock_vpd_data[7]}"
       ;;
    "in_anglvel_z_base_calibbias")
       echo "${mock_vpd_data[8]}"
       ;;
  esac
}

DEVICE="dummy0"

# Redo global variable initializaton.
IIO_DEVICE_PATH="${IIO_DEVICES}/${DEVICE}"
IIO_SINGLE_SENSOR_DIR=true

# Test with one first accel vpd data too big.
test_name="Max VPD base[Z]"
mock_vpd_data=(0 0 1000 0 0 0 0 0 0)
if calibration_values_viable; then
  exit 1
fi

# Test with one first accel vpd data too small.
test_name="Min VPD base[Z]"
mock_vpd_data=(0 0 -1000 0 0 0 0 0 0)
if calibration_values_viable; then
  exit 1
fi

# Test with one second accel vpd data too big.
test_name="Max VPD lid[Z]"
mock_vpd_data=(0 0 0 0 0 1000 0 0 0)
if calibration_values_viable; then
  exit 1
fi

# Test with one gyro vpd data too big.
test_name="Max VPD gyro base[X]"
mock_vpd_data=(0 0 0 0 0 0 40000 0 0)
if calibration_values_viable; then
  exit 1
fi

# Tet with no VPD data at all.
test_name="No VPD"
mock_vpd_data=()
if ! calibration_values_viable; then
  exit 1
fi

# Test with one valid vpd data.
test_name="Good VPD"
mock_vpd_data=(0 0 10 0 -20 0)
if ! calibration_values_viable; then
  exit 1
fi

# Test checking these vpd values above are written correcly to sensors.
TYPE="accel"
for location in ${SENSOR_LOCATIONS}; do
  LOCATION_PATH="${TEST_DIR}/test_location_${location}.txt"
  test_name="set_calibration_values_good_${location}"
  set_calibration_values
  diff "${ACCEL_TEMP_DIR}/${test_name}.out" "${TEST_DIR}/${test_name}.golden"
  if [ $? -ne 0 ]; then
    exit 1
  fi
done
