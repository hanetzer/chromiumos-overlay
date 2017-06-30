# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="13689bfb6a3716e683b44b92e6fe8777ea526b4a"
CROS_WORKON_TREE="33f52f363b8f5a193fd95bd6de61080cff8bece6"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Android libcamera_metadata"

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
	emake libcamera_metadata
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