# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1b4096f92f8b9e864f90452b4d3fe68a2b428154"
CROS_WORKON_TREE="edde50ea674de221e3c09a8060f1fcc6dde799a2"
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
	!media-libs/arc-camera3-libsync
	media-libs/libexif
	media-libs/libsync
	media-libs/minigbm
	virtual/jpeg:0"

DEPEND="${RDEPEND}
	media-libs/arc-camera3-android-headers
	media-libs/arc-camera3-libcamera_client
	media-libs/arc-camera3-libcamera_metadata
	media-libs/arc-camera3-libcbm
	media-libs/libyuv
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} camera3_test
}

src_install() {
	dobin camera3_test/arc_camera3_test
}