# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="0216e959f16f4173784f0336c542975e6c3fa68c"
CROS_WORKON_TREE="b34f0c73590d1c819f389ccd5d986a9d86207050"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Android libcamera_metadata"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="!media-libs/arc-camera3-libcamera_metadata"

DEPEND="${RDEPEND}
	media-libs/cros-camera-android-headers"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cd android
	cw_emake libcamera_metadata
}

src_install() {
	local INCLUDE_DIR="/usr/include/android"
	local LIB_DIR="/usr/$(get_libdir)"
	local SRC_DIR="android/libcamera_metadata"

	dolib "${SRC_DIR}/libcamera_metadata.pic.a"

	insinto "${INCLUDE_DIR}/system"
	doins "${SRC_DIR}/include/system"/*.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		"${SRC_DIR}/libcamera_metadata.pc.template" > \
		"${SRC_DIR}/libcamera_metadata.pc"
	insinto "${LIB_DIR}/pkgconfig"
	doins "${SRC_DIR}/libcamera_metadata.pc"
}
