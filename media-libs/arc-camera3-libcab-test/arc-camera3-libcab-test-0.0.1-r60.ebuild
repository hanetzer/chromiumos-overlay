# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="3b8cbef069fb8cd4a55b838f4c28896d6882a748"
CROS_WORKON_TREE="2b19ba299bd9d0a8ed984c7e623014a4158e2c6b"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Test for camera algorithm bridge library"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	media-libs/arc-camera3-libcab"

DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} libcab_test
}

src_install() {
	dobin common/libcab_test
	dolib common/libcam_algo.so
}
