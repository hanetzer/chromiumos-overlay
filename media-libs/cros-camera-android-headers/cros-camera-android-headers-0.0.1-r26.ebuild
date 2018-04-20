# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="892cc636f68d492a24f06913236ef0cc96cdc9e4"
CROS_WORKON_TREE="ee39f780e08a5562744eda3ae11fc02be0608832"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-workon

DESCRIPTION="Android header files required for building camera HAL v3"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="!media-libs/arc-camera3-android-headers"

src_compile() {
	true
}

src_install() {
	local INCLUDE_DIR="/usr/include/android"
	local LIB_DIR="/usr/$(get_libdir)"
	local PC_FILE="android/header_files/cros-camera-android-headers.pc"

	insinto "${INCLUDE_DIR}"
	doins -r android/header_files/include/*

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" \
		"${PC_FILE}.template" > "${PC_FILE}"
	insinto "${LIB_DIR}/pkgconfig"
	doins ${PC_FILE}
}
