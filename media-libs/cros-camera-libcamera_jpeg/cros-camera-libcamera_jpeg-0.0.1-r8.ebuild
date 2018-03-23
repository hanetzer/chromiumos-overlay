# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="7477348b3f5adb0e4c3f6a4798282ae53d5d4d9a"
CROS_WORKON_TREE="55d06a9ef1b32261d9bdb66d93b37d84229c3045"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Chrome OS camera HAL Jpeg compressor util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="
	!media-libs/arc-camera3-libcamera_jpeg
	virtual/jpeg:0"

DEPEND="${RDEPEND}
	media-libs/libyuv
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libcamera_jpeg
}

src_install() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.a common/libcamera_jpeg.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/cros-camera/jpeg_compressor.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcamera_jpeg.pc.template > common/libcamera_jpeg.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcamera_jpeg.pc
}
