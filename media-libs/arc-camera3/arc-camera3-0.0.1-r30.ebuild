# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2e6ab17b0a1f55077f8de8ca871884a73975b18c"
CROS_WORKON_TREE="99870bc0870c9fb5f9fc5184145ac6d5040d30fc"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera HAL v3 service. The service is in charge of accessing
camera device. It uses unix domain socket to build a synchronous channel."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/libmojo
	media-libs/minigbm
	x11-libs/libdrm
	virtual/arc-camera3-hal"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_compile() {
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} hal_adapter
	emake BASE_VER=${LIBCHROME_VERS} libcbm
}

src_install() {
	local INCLUDE_DIR="/usr/include"
	local LIB_DIR="/usr/$(get_libdir)"

	dobin hal_adapter/arc_camera3_service

	dolib common/libcbm.so

	insinto "${INCLUDE_DIR}"
	doins include/arc/camera_buffer_mapper.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		common/libcbm.pc.template > common/libcbm.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcbm.pc
}

src_test() {
	emake BASE_VER=${LIBCHROME_VERS} tests

	if use x86 || use amd64; then
		./common/future_unittest || die "future unit tests failed!"
		./common/camera_buffer_mapper_unittest || \
			die "camera_buffer_mapper unit tests failed!"
	fi
}