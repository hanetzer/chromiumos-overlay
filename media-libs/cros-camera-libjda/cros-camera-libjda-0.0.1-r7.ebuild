# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="8e402c9fd96243cb9c177798c26e70a9cfda4d51"
CROS_WORKON_TREE="6a257a1664aa3026074da9a10292080853792cee"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Library for usgin Jpeg Decode Accelerator in Chrome"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND=""

DEPEND="${RDEPEND}
	chromeos-base/libmojo
	media-libs/cros-camera-libcamera_common
	media-libs/cros-camera-libcamera_ipc
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libjda
}

src_install() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib common/jpeg/libjda.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/cros-camera/jpeg_decode_accelerator.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/jpeg/libjda.pc.template > common/jpeg/libjda.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/jpeg/libjda.pc
}
