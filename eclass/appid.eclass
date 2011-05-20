# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
# $Header: $

#
# appid.eclass
#
# Adds a mechanism for setting the image APPID.
#

# Initializes /etc/lsb-release with an APPID.
#
# $1 - APPID
doappid() {
	dodir etc
	echo "CHROMEOS_RELEASE_APPID=${1}" >"${D}/etc/lsb-release"
}
