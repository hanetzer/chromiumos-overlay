#!/bin/sh
# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script is called by udev to determine if a given udev node has any parent
# node that is a usb_device. If the device node does, then the parent usb_device
# node has its group set to the usb group (blocking access to it by the
# chrome-usb group). The net effect is that any device which is claimed by any
# driver or subsystem may not be accessed by chrome-usb, but that any device
# which is _not_ claimed will be accessible. usb_interfaces are ignored, unless
# they happend to be hubs, in which case the root hub device is locked down.
# This is in support of the Chrome USB extension API.

extract_root_usb_device() {
  echo $1 | egrep -o '^.+/usb[^/]+/[^/]+'
}

extract_root_usb_hub() {
  echo $1 | egrep -o '^.+/usb[^/]+'
}

extract_device_property() {
  udevadm info --query=property --path="$1" | grep "^$2" | cut -d= -f2-
}

extract_device_name() {
  extract_device_property "$1" 'DEVNAME'
}

extract_device_type() {
  extract_device_property "$1" 'DEVTYPE'
}

extract_device_driver() {
  extract_device_property "$1" 'DRIVER'
}

remove_chrome_usb_access() {
  chgrp usb $1
}

root_hub=`extract_root_usb_hub $1`
root_device=`extract_root_usb_device $1`
if [ -n "$root_device" ] || [ -n "$root_hub" ]; then
  device_type=`extract_device_type $1`
  device_driver=`extract_device_driver $1`
  if [ "$device_type" = "usb_device" ]; then
    exit 0
  elif [ "$device_driver" = "hub" ]; then
    remove_chrome_usb_access `extract_device_name $root_hub`
  elif [ "$device_type" != "usb_interface" ]; then
    remove_chrome_usb_access `extract_device_name $root_device`
  fi
fi
