# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="6961f9315c5c907045aeedfc8744c08da7a0d7b8"
CROS_WORKON_TREE="619ce318c0dcb264eed413ffa0a110e23bc4d119"
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

src_compile() {
	asan-setup-env
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	cd android
	emake libcamera_client
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
