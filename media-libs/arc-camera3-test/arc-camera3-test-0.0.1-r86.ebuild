# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="7d49d11a1c634b0b3954e914ae88f754d259cf0d"
CROS_WORKON_TREE="a1b5c28d4c5f40f821497a414ccf1fa9b1eea386"
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
	media-libs/libexif
	media-libs/minigbm
	virtual/jpeg:0"

DEPEND="${RDEPEND}
	media-libs/arc-camera3-android-headers
	media-libs/arc-camera3-libcamera_client
	media-libs/arc-camera3-libcamera_metadata
	media-libs/arc-camera3-libsync
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
