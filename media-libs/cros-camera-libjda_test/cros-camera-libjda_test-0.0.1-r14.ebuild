# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("ef7de27db02c5e2a4b6d071d0540bf1e9e04f5f6" "c73d786769ed583ffa3e8ef52b4047d15cdfaec5")
CROS_WORKON_TREE=("6589055d0d41e7fc58d42616ba5075408d810f7d" "a34ebbec33942126d693ec398839c5c1b8d94b0f" "b257beec642f3448ad2bfa7f84ac4448a8b2129e" "8f3859492d0228b565f17f02fe138f81617c6415" "99d4f98c0151c7e25437bb625f114bde347170d5")
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
