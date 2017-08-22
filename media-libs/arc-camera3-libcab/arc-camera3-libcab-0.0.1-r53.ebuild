# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f9f85e9803d2f5442d57427ba1a11b0d03d4bcc2"
CROS_WORKON_TREE="bda64e0e86434a6ea01b746a9b4c43c1447c09f7"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Camera algorithm bridge library for 3A isolation"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=""

DEPEND="${RDEPEND}
	chromeos-base/libmojo"

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
