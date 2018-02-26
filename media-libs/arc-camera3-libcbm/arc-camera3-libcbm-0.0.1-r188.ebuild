# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="ba9335d0de2982d5793614c1be281e0ce10c8c3a"
CROS_WORKON_TREE="705a031d412896a5f316c8e9ce86e1ab2a0f439a"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera HAL v3 buffer manager."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="
	media-libs/minigbm
	x11-libs/libdrm"

DEPEND="${RDEPEND}
	media-libs/arc-camera3-android-headers
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libcbm
}

src_install() {
	local INCLUDE_DIR="/usr/include/arc"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib common/libcbm.so

	insinto "${INCLUDE_DIR}"
	doins include/arc/camera_buffer_manager.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcbm.pc.template > common/libcbm.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcbm.pc
}

src_test() {
	emake BASE_VER=${LIBCHROME_VERS} tests

	if use x86 || use amd64; then
		./common/camera_buffer_manager_unittest || \
			die "camera_buffer_manager unit tests failed!"
	fi
}
