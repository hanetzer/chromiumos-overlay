# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="7d49d11a1c634b0b3954e914ae88f754d259cf0d"
CROS_WORKON_TREE="a1b5c28d4c5f40f821497a414ccf1fa9b1eea386"
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
