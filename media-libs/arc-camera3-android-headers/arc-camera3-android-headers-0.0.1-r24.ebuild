# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="3a9271ba34559b75c9202fd0e6c163dfc3cbd711"
CROS_WORKON_TREE="e378e5c94f858ce4df39e44dc46f4ae8613d87b5"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-workon

DESCRIPTION="Android header files required for building camera HAL v3"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_compile() {
	true
}

src_install() {
	local INCLUDE_DIR="/usr/include/android"
	local LIB_DIR="/usr/$(get_libdir)"
	local PC_FILE="android/header_files/arc-camera3-android-headers.pc"

	insinto "${INCLUDE_DIR}"
	doins -r android/header_files/include/*

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" \
		"${PC_FILE}.template" > "${PC_FILE}"
	insinto "${LIB_DIR}/pkgconfig"
	doins ${PC_FILE}
}
