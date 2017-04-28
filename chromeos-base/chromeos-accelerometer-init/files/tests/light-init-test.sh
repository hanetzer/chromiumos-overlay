#!/bin/bash
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Unit test for udev script udev/accelerometer-init.sh

export LC_ALL=C
LIGHT_UNIT_TEST=true

LIGHT_TEMP_TEMPLATE=test_fw.XXXXXX
LIGHT_TEMP_DIR=$(mktemp -d --tmpdir "${LIGHT_TEMP_TEMPLATE}")

TEST_DIR=$(dirname "$0")
SCRIPT_DIR="$(dirname "${TEST_DIR}")/udev"

cleanup() {
  local rv=$?
  if [ ${rv} -eq 0 ]; then
    rm -rf "${LIGHT_TEMP_DIR}"
  else
    echo "${test_name} Failed: logs left in ${LIGHT_TEMP_DIR}"
  fi
  exit ${rv}
}

trap cleanup EXIT INT TERM

. "${SCRIPT_DIR}/light-init.sh" dummy0 illuminance

declare -a mock_vpd_data
declare test_name

# Override set_sysfs_entry to store which sysfs attributes the test changes.
set_sysfs_entry() {
  echo "$1=$2" >> "${LIGHT_TEMP_DIR}/${test_name}.out"
}

# Override vpd_get_value to return mock data.
vpd_get_value() {
  case "$1" in
    "als_cal_intercept")
       echo "${mock_vpd_data[0]}"
       ;;
    "als_cal_slope")
       echo "${mock_vpd_data[1]}"
       ;;
    *)
       echo "Invalid request: $1"
  esac
}

# Test checking these vpd values above are written correcly to sensors.
test_name="set_calibration_light"
mock_vpd_data=(-99 10000)
set_calibration_values get_calibration_from_vpd
diff "${LIGHT_TEMP_DIR}/${test_name}.out" "${TEST_DIR}/${test_name}.golden"
if [ $? -ne 0 ]; then
  exit 1
fi

TYPE="proximity"
test_name="set_calibration_prox"
# Nothing should happen yet, output file should be empty.
set_calibration_values get_calibration_from_vpd
if [ -s "${LIGHT_TEMP_DIR}/${test_name}.out" ]; then
  exit 1
fi
