# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="8e402c9fd96243cb9c177798c26e70a9cfda4d51"
CROS_WORKON_TREE="6a257a1664aa3026074da9a10292080853792cee"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Chrome OS HAL common util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="!media-libs/arc-camera3-libcamera_common"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	asan-setup-env
	cw_emake BASE_VER=${LIBCHROME_VERS} libcamera_common
}

src_install() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.a common/libcamera_common.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/cros-camera/common.h \
		include/cros-camera/future.h \
		include/cros-camera/future_internal.h \
		include/cros-camera/camera_thread.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcamera_common.pc.template > common/libcamera_common.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcamera_common.pc
}

src_test() {
	emake BASE_VER=${LIBCHROME_VERS} tests

	if use x86 || use amd64; then
		./common/future_unittest || die "future unit tests failed!"
	fi
}
