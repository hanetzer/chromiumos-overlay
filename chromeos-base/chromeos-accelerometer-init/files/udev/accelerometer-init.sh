#!/bin/sh
# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up default trigger for cros-ec-accel devices

DEVICE=$1
IIO_DEVICES=/sys/bus/iio/devices
IIO_DEVICE_PATH=${IIO_DEVICES}/${DEVICE}

# Sets pre-determined calibration values for the accelerometers.
# The calibration values are fetched from the VPD.
dump_vpd_log --full --stdout | \
  egrep "\"in_accel_[xyz]_(lid|base)_calib(bias|scale)\"=" | sed 's/\"//g' | \
  while read key_value; do
    CALIBRATION_NAME=$(echo ${key_value} | cut -d= -f1)
    CALIBRATION_VALUE=$(echo ${key_value} | cut -d= -f2)
    echo ${CALIBRATION_VALUE} > ${IIO_DEVICE_PATH}/${CALIBRATION_NAME}
  done

echo 0 > ${IIO_DEVICES}/iio_sysfs_trigger/add_trigger
cat ${IIO_DEVICES}/iio_sysfs_trigger/trigger0/name > \
    ${IIO_DEVICE_PATH}/trigger/current_trigger

# Set up fields to probe on trigger.
echo 1 > ${IIO_DEVICE_PATH}/scan_elements/in_accel_x_base_en
echo 1 > ${IIO_DEVICE_PATH}/scan_elements/in_accel_y_base_en
echo 1 > ${IIO_DEVICE_PATH}/scan_elements/in_accel_z_base_en
echo 1 > ${IIO_DEVICE_PATH}/scan_elements/in_accel_x_lid_en
echo 1 > ${IIO_DEVICE_PATH}/scan_elements/in_accel_y_lid_en
echo 1 > ${IIO_DEVICE_PATH}/scan_elements/in_accel_z_lid_en
echo 0 > ${IIO_DEVICE_PATH}/scan_elements/in_timestamp_en

# We only fetch 1 sample at a time as Chrome is the only consumer.
echo 1 > ${IIO_DEVICE_PATH}/buffer/length
echo 1 > ${IIO_DEVICE_PATH}/buffer/enable

# Allow chronos to trigger the accelerometer.
chgrp chronos ${IIO_DEVICES}/trigger0/trigger_now
chmod g+w ${IIO_DEVICES}/trigger0/trigger_now
