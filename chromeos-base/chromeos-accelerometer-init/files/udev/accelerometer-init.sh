#!/bin/sh
# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up default trigger for cros-ec-accel devices

DEVICE=$1
IIO_DEVICES=/sys/bus/iio/devices
CROS_EC_PATH=/sys/class/chromeos/cros_ec
IIO_DEVICE_PATH="${IIO_DEVICES}/${DEVICE}"
LOCATION_PATH="${IIO_DEVICE_PATH}/location"
IIO_SINGLE_SENSOR_DIR=false
test -f "${LOCATION_PATH}" && IIO_SINGLE_SENSOR_DIR=true

if "${IIO_SINGLE_SENSOR_DIR}"; then
  LOCATION=$(cat "${LOCATION_PATH}")
fi

# Sets pre-determined calibration values for the accelerometers.
# The calibration values are fetched from the VPD.
dump_vpd_log --full --stdout | \
  egrep "\"in_accel_[xyz]_(lid|base)_calib(bias|scale)\"=" | sed 's/\"//g' | \
  while read key_value; do
    IFS='=' read CALIBRATION_NAME CALIBRATION_VALUE <<EOL
${key_value}
EOL

    if "${IIO_SINGLE_SENSOR_DIR}"; then
      # After kernel 3.18, it has separated iio:device for each accelerometer.
      # It needs to read values from in_accel_[xyz]_(lid|base)_calibbias in
      # VPD and writes it into in_accel_[xyz]_calibbias in sysfs.
      # _caliscale is not required now.
      case "${CALIBRATION_NAME}" in
        *${LOCATION}_calibbias)
          NEW_CALIBRATION_NAME=$(echo "${CALIBRATION_NAME}" |
                                 sed 's/${LOCATION}_//;')
          echo "${CALIBRATION_VALUE}" > "${IIO_DEVICE_PATH}/${NEW_CALIBRATION_NAME}"
          ;;
      esac
    else
      echo "${CALIBRATION_VALUE}" > "${IIO_DEVICE_PATH}/${CALIBRATION_NAME}"
    fi
  done

# Be sure the sysfs trigger module is present.
modprobe -q iio_trig_sysfs
echo 0 > "${IIO_DEVICES}/iio_sysfs_trigger/add_trigger"
cat "${IIO_DEVICES}/iio_sysfs_trigger/trigger0/name" > \
    "${IIO_DEVICE_PATH}/trigger/current_trigger"

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
chgrp chronos "${IIO_DEVICES}/trigger0/trigger_now"
chmod g+w "${IIO_DEVICES}/trigger0/trigger_now"

# Allow powerd to set the keyboard wake angle.
if "${IIO_SINGLE_SENSOR_DIR}"; then
  chgrp power ${CROS_EC_PATH}/kb_wake_angle
  chmod g+w ${CROS_EC_PATH}/kb_wake_angle
else
  chgrp power ${IIO_DEVICE_PATH}/in_angl_offset
  chmod g+w ${IIO_DEVICE_PATH}/in_angl_offset
fi
