# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="ecb6ac8ae2ea3804feaa30ee79c3c1f287b7a5cf"
CROS_WORKON_TREE="6bb49e8fb707238ccb2243e72a1b635c64da940d"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera HAL v3 Jpeg compressor util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="virtual/jpeg:0"

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
	local INCLUDE_DIR="/usr/include/arc"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.a common/libcamera_jpeg.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/arc/jpeg_compressor.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcamera_jpeg.pc.template > common/libcamera_jpeg.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcamera_jpeg.pc
}
