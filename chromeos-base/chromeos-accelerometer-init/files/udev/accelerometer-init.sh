#!/bin/sh
# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up default trigger for cros-ec-accel devices

DEVICE=$1
TYPE=$2
IIO_DEVICES="/sys/bus/iio/devices"
CROS_EC_PATH="/sys/class/chromeos/cros_ec"
IIO_DEVICE_PATH="${IIO_DEVICES}/${DEVICE}"
LOCATION_PATH="${IIO_DEVICE_PATH}/location"
IIO_SINGLE_SENSOR_DIR=false
SYSFSTRIG_NAME="sysfstrig0"

trigger=""

test -f "${LOCATION_PATH}" && IIO_SINGLE_SENSOR_DIR=true

# Sets pre-determined calibration values for the accelerometers.
# The calibration values are fetched from the VPD.
set_calibration_values() {
  local axis location value_type name value
  local locations="lid base"
  local value_types="bias scale"

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

        echo "${value}" >"${IIO_DEVICE_PATH}/${name}"
      done
    done
  done
}

set_calibration_values

if [ "${TYPE}" = "anglvel" ]; then
  # No need to set buffer for gyroscope, not used by chrome yet.
  exit
fi

# Be sure the sysfs trigger module is present.
modprobe -q iio_trig_sysfs
echo 0 > "${IIO_DEVICES}/iio_sysfs_trigger/add_trigger"

# the name of the trigger is "sysfstrig0":
# sysfstrig are the generic names of iio_sysfs_trigger, 0 is the index passed at
# creaion.
echo "${SYSFSTRIG_NAME}" > "${IIO_DEVICE_PATH}/trigger/current_trigger"

# Find the name of the created trigger.
for trigger in ${IIO_DEVICES}/trigger*; do
  if grep -q "${SYSFSTRIG_NAME}" "${trigger}/name"; then
    break
  fi
done

echo 0 > "${IIO_DEVICE_PATH}/scan_elements/in_timestamp_en"

if "${IIO_SINGLE_SENSOR_DIR}"; then
  # Fields for current kernel
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_x_en"
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_y_en"
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_z_en"
else
  # Set up fields to probe on trigger.
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_x_base_en"
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_y_base_en"
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_z_base_en"
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_x_lid_en"
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_y_lid_en"
  echo 1 > "${IIO_DEVICE_PATH}/scan_elements/in_accel_z_lid_en"
fi

# We only fetch 1 sample at a time as Chrome is the only consumer.
echo 1 > "${IIO_DEVICE_PATH}/buffer/length"
echo 1 > "${IIO_DEVICE_PATH}/buffer/enable"

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
