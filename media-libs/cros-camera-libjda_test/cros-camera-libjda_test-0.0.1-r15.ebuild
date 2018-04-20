# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("892cc636f68d492a24f06913236ef0cc96cdc9e4" "e2f56c1e321a090f7a3f5a4a058311ab5bb20126")
CROS_WORKON_TREE=("6589055d0d41e7fc58d42616ba5075408d810f7d" "16108c9244a2e1a125d32d3ebdf056a52b068b11" "809f3732fa1d07e62d5ae7b92d0e10e8722f92fb" "8f3859492d0228b565f17f02fe138f81617c6415" "99d4f98c0151c7e25437bb625f114bde347170d5")
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
	"build common include mojo"
	"common-mk"
)
PLATFORM_GYP_FILE="common/jpeg/libjda_test.gyp"

inherit cros-camera cros-workon

DESCRIPTION="End to end test for JPEG decode accelerator"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="dev-cpp/gtest"

DEPEND="${RDEPEND}
	media-libs/cros-camera-libjda"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	dobin "${OUT}/libjda_test"
}
