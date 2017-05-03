# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="844dfff5adf2c5cb6dda4936337f9f1aef328433"
CROS_WORKON_TREE="d731efe3c7e723976344a1e4fc15872c13a587f6"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Android libsync"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND=""

DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	cd android
	emake libsync
}

src_install() {
	local INCLUDE_DIR="/usr/include/android"
	local LIB_DIR="/usr/$(get_libdir)"
	local SRC_DIR="android/libsync"

	dolib "${SRC_DIR}/libsync.pic.a"

	insinto "${INCLUDE_DIR}/sync"
	doins "${SRC_DIR}/include/sync/sync.h"

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		"${SRC_DIR}/libsync.pc.template" > "${SRC_DIR}/libsync.pc"
	insinto "${LIB_DIR}/pkgconfig"
	doins "${SRC_DIR}/libsync.pc"
}
