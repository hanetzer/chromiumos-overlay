# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="266a72e3439d530f6be2009f7e8097456ff73bad"
CROS_WORKON_TREE="12694cb38d9d0d2c39dffbfe95cf15832a32d3e7"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Chrome OS camera HAL v3 V4L2 device utility."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND=""

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libcamera_v4l2_device
}

src_install() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.a common/v4l2_device/libcamera_v4l2_device.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/cros-camera/v4l2_device.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/v4l2_device/libcamera_v4l2_device.pc.template > common/v4l2_device/libcamera_v4l2_device.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/v4l2_device/libcamera_v4l2_device.pc
}
