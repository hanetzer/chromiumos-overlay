#!/bin/sh
# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up default trigger for cros-ec-accel devices

DEVICE=$1
TYPE=$2

: ${ACCELEROMETER_UNIT_TEST:=false}

IIO_DEVICES="/sys/bus/iio/devices"
CROS_EC_PATH="/sys/class/chromeos/cros_ec"
IIO_DEVICE_PATH="${IIO_DEVICES}/${DEVICE}"
LOCATION_PATH="${IIO_DEVICE_PATH}/location"
IIO_SINGLE_SENSOR_DIR=false
SYSFSTRIG_NAME="sysfstrig0"

VPD_DATA_VALID_FILE="/var/lib/vpd_data_valid"
SENSOR_LOCATIONS="lid base"
SENSOR_TYPES="accel anglvel"
SENSOR_CALIB_TYPES="bias scale"

trigger=""

# We are adding around 2x margin to the worse measurements. If we add to use
# an offset of .25g, that would be a 25% error rate, making the data useless.
ABS_MAX_CALIB_accel=256          # .250 g

# A 16dps is also a huge offset. For instance, BMI160 maximal acceptable offset
# is 5dps for the gyroscope.
ABS_MAX_CALIB_anglvel=16384      # 16 dps

# Check if any calibration value are way out.
# It could be an indication the calibration test was not done properly in the
# factory.
calibration_values_viable() {
  local abs_max
  local max_value
  local min_value
  local location
  local sensor_type
  local name
  local value

  for sensor_type in ${SENSOR_TYPES}; do
    eval abs_max=\""\${ABS_MAX_CALIB_${sensor_type}}"\"
    max_value=${abs_max}
    min_value=$(( abs_max * -1 ))

    for location in ${SENSOR_LOCATIONS}; do
      for axis in x y z; do
        name="in_${sensor_type}_${axis}_${location}_calibbias"
        value="$(vpd_get_value "${name}")"
        if [ -z "${value}" ]; then
          continue
        fi
        if [ ${value} -gt ${max_value} -o \
             ${value} -lt ${min_value} ]; then
          return 1
        fi
      done
    done
  done
  return 0
}

# Hook for unit tests: Test script redefines this function to monitor what is
# written to sysfs.
set_sysfs_entry() {
  local name="$1"
  local value="$2"

  echo "${value}" > "${name}"
}

# Sets pre-determined calibration values for the accelerometers.
# The calibration values are fetched from the VPD.
set_calibration_values() {
  local axis location value_type name value
  local locations="${SENSOR_LOCATIONS}"
  local value_types="${SENSOR_CALIB_TYPES}"
  local name
  local value

  # After kernel 3.18, it has separated iio:device for each accelerometer.
  # It needs to read values from in_accel_[xyz]_(lid|base)_calibbias in VPD and
  # writes it into in_${TYPE}_[xyz]_calibbias in sysfs.  _caliscale is not
  # required now.
  if "${IIO_SINGLE_SENSOR_DIR}"; then
    locations="$(cat "${LOCATION_PATH}")"
    value_types="bias"
  fi

  for location in ${locations}; do
    for value_type in ${value_types}; do
      for axis in x y z; do
        name="in_${TYPE}_${axis}_${location}_calib${value_type}"
        value="$(vpd_get_value "${name}")"
        if [ -z "${value}" ]; then
          continue
        fi

        if "${IIO_SINGLE_SENSOR_DIR}"; then
          # Use a new name without location.
          name="in_${TYPE}_${axis}_calib${value_type}"
        fi

        set_sysfs_entry "${IIO_DEVICE_PATH}/${name}" "${value}"
      done
    done
  done
}

main() {
  local trigger

  if [ -f "${LOCATION_PATH}" ]; then
    IIO_SINGLE_SENSOR_DIR=true
  fi

  # Check once if the VPD data are valid. If a single sensor data is erroneous,
  # ignore all sensor data from VPD.
  if [ ! -f "${VPD_DATA_VALID_FILE}" ]; then
    if calibration_values_viable; then
      echo "valid" > "${VPD_DATA_VALID_FILE}"
    else
      echo "invalid" > "${VPD_DATA_VALID_FILE}"
    fi
  fi
  if grep -qe "^valid$" "${VPD_DATA_VALID_FILE}"; then
    set_calibration_values
  fi

  if [ "${TYPE}" = "anglvel" ]; then
    # No need to set buffer for gyroscope, not used by chrome yet.
    exit
  fi

  # Be sure the sysfs trigger module is present.
  modprobe -q iio_trig_sysfs
  set_sysfs_entry "${IIO_DEVICES}/iio_sysfs_trigger/add_trigger" 0

  # The name of the trigger is "sysfstrig0":
  # sysfstrig are the generic names of iio_sysfs_trigger, 0 is the index passed
  # at creation.
  set_sysfs_entry "${IIO_DEVICE_PATH}/trigger/current_trigger" \
                  "${SYSFSTRIG_NAME}"

  # Find the name of the created trigger.
  for trigger in "${IIO_DEVICES}"/trigger*; do
    if grep -q "${SYSFSTRIG_NAME}" "${trigger}/name"; then
      break
    fi
  done

  set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_timestamp_en" 0

  if "${IIO_SINGLE_SENSOR_DIR}"; then
    # Fields for current kernel.
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_x_en" 1
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_y_en" 1
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_z_en" 1
  else
    # Set up fields to probe on trigger.
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_x_base_en" 1
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_y_base_en" 1
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_z_base_en" 1
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_x_lid_en" 1
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_y_lid_en" 1
    set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_z_lid_en" 1
  fi

  # We only fetch 1 sample at a time as Chrome is the only consumer.
  set_sysfs_entry "${IIO_DEVICE_PATH}/buffer/length" 1
  set_sysfs_entry "${IIO_DEVICE_PATH}/buffer/enable" 1

  # Allow chronos to trigger the accelerometer.
  chgrp chronos "${trigger}/trigger_now"
  chmod g+w "${trigger}/trigger_now"

  # Allow powerd to set the keyboard wake angle.
  if "${IIO_SINGLE_SENSOR_DIR}"; then
    chgrp power "${CROS_EC_PATH}/kb_wake_angle"
    chmod g+w "${CROS_EC_PATH}/kb_wake_angle"
  else
    chgrp power "${IIO_DEVICE_PATH}/in_angl_offset"
    chmod g+w "${IIO_DEVICE_PATH}/in_angl_offset"
  fi
}

# invoke main if not in test mode, otherwise let the test code call.
if ! ${ACCELEROMETER_UNIT_TEST}; then
  main "$@"
fi
