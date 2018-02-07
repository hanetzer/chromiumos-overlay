# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="e78788bdc7c9a1b030a07e1e811b23f1eabf88b8"
CROS_WORKON_TREE="201003644f2e5621620452d8a9cfd90e44978b08"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Android libcamera_client"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND=""

DEPEND="${RDEPEND}
	media-libs/arc-camera3-android-headers"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cd android
	cw_emake libcamera_client
}

src_install() {
	local INCLUDE_DIR="/usr/include/android"
	local LIB_DIR="/usr/$(get_libdir)"
	local SRC_DIR="android/libcamera_client"

	dolib "${SRC_DIR}/libcamera_client.pic.a"

	insinto "${INCLUDE_DIR}/camera"
	doins "${SRC_DIR}/include/camera"/*.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		"${SRC_DIR}/libcamera_client.pc.template" > \
		"${SRC_DIR}/libcamera_client.pc"
	insinto "${LIB_DIR}/pkgconfig"
	doins "${SRC_DIR}/libcamera_client.pc"
}
