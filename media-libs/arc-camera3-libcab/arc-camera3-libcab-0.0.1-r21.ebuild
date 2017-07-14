# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="bf21bcfb76b4215f7cc5e0532a355c7f6e447240"
CROS_WORKON_TREE="6d88cbe319c0a2f88c564d280d7493359c30bc99"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Camera algorithm bridge library for 3A isolation"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libmojo"

DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} libcab
}

src_install() {
	local INCLUDE_DIR="/usr/include/arc"
	local LIB_DIR="/usr/$(get_libdir)"

	dobin common/arc_camera_algo

	dolib common/libcab.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/arc/camera_algorithm.h
	doins include/arc/camera_algorithm_bridge.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		"common/libcab.pc.template" > "common/libcab.pc"
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcab.pc

	insinto /etc/init
	doins common/init/arc-camera-algo.conf

	insinto "/usr/share/policy"
	doins common/arc-camera-algo.policy
}
