# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="1e5befcb09442edf0ca420f6c8b02f382a4579f0"
CROS_WORKON_TREE="2f27da4d730a756e11b762873396cbf0345bbe5c"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Camera algorithm bridge library for proprietary camera algorithm
isolation"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="!media-libs/arc-camera3-libcab"

DEPEND="${RDEPEND}
	chromeos-base/libmojo
	media-libs/cros-camera-libcamera_common
	media-libs/cros-camera-libcamera_ipc"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libcab
}

src_install() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	dobin common/cros_camera_algo

	dolib common/libcab.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/cros-camera/camera_algorithm.h
	doins include/cros-camera/camera_algorithm_bridge.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		"common/libcab.pc.template" > "common/libcab.pc"
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcab.pc

	insinto /etc/init
	doins common/init/cros-camera-algo.conf

	insinto "/usr/share/policy"
	newins common/cros-camera-algo-${ARCH}.policy cros-camera-algo.policy
}
