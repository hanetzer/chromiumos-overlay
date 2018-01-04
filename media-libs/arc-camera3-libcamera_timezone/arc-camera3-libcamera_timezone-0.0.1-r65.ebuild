# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="c495ab89a4482b07230a128ca9638f7e058bcf26"
CROS_WORKON_TREE="0884cd7e6de5345119f42ba39fc4a0aa44f634a7"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera HAL v3 Time zone util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND=""

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
	local INCLUDE_DIR="/usr/include/arc"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.a common/libcamera_timezone.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/arc/timezone.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcamera_timezone.pc.template > common/libcamera_timezone.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcamera_timezone.pc
}
