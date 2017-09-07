# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="4db82404c343a6987f0aafa29f39e9093d04e248"
CROS_WORKON_TREE="1e0386cf797e3f95f22bbeb2dda267537060f292"
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
	virtual/pkgconfig"

src_compile() {
	asan-setup-env
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} libcamera_jpeg
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
