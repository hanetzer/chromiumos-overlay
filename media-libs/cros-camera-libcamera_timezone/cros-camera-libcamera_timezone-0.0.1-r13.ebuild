# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="266a72e3439d530f6be2009f7e8097456ff73bad"
CROS_WORKON_TREE="12694cb38d9d0d2c39dffbfe95cf15832a32d3e7"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Chrome OS camera HAL Time zone util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="!media-libs/arc-camera3-libcamera_timezone"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	asan-setup-env
	cw_emake BASE_VER=${LIBCHROME_VERS} libcamera_timezone
}

src_install() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.a common/libcamera_timezone.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/cros-camera/timezone.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcamera_timezone.pc.template > common/libcamera_timezone.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcamera_timezone.pc
}
