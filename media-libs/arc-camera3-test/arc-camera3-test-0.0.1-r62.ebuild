# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a297ac2b17b03039be6faac0bb23316695b68bdd"
CROS_WORKON_TREE="b44fece13ec250bbf1478a1bf33eb55f6f350fda"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME='../platform/arc-camera'

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera HALv3 native test."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="
	dev-cpp/gtest
	media-libs/arc-camera3-libcamera_metadata
	media-libs/arc-camera3-libsync
	media-libs/libexif
	media-libs/minigbm
	virtual/jpeg:0"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_compile() {
	asan-setup-env
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} camera3_test
}

src_install() {
	dobin camera3_test/arc_camera3_test
}
