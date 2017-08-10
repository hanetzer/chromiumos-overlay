# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="9d35fce9ee716dd9c7cb09633c332d08a01faedf"
CROS_WORKON_TREE="cf86c4633fcae4be66f932652938b9d1b9a609f6"
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
