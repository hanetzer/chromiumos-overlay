# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="dcf78b662f4f4ce8b3bdd2b9326ab44068c694f3"
CROS_WORKON_TREE="6faef7db268542167f946288b49ef308296d0484"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Android libsync"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND=""

DEPEND="${RDEPEND}
	media-libs/arc-camera3-android-headers"

src_compile() {
	asan-setup-env
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
