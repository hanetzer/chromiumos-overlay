# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_PROJECT=(
	"chromiumos/platform/arc-camera"
	"chromiumos/platform2"
)
CROS_WORKON_LOCALNAME=(
	"../platform/arc-camera"
	"../platform2"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform/arc-camera"
	"${S}/platform2"
)
CROS_WORKON_SUBTREE=(
	"build common include"
	"common-mk"
)
PLATFORM_GYP_FILE="common/libcab_test.gyp"

inherit cros-camera cros-workon

DESCRIPTION="Test for camera algorithm bridge library"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"

RDEPEND="
	dev-cpp/gtest
	!media-libs/arc-camera3-libcab-test
	media-libs/cros-camera-libcab"

DEPEND="${RDEPEND}"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	dobin "${OUT}/libcab_test"
	dolib.so "${OUT}/lib/libcam_algo.so"
}
