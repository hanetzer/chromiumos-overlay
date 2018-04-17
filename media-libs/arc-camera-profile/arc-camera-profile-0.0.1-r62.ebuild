# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("ef7de27db02c5e2a4b6d071d0540bf1e9e04f5f6" "c73d786769ed583ffa3e8ef52b4047d15cdfaec5")
CROS_WORKON_TREE=("6589055d0d41e7fc58d42616ba5075408d810f7d" "17340e95cb7f73be9632744824d30b2951bfbe80" "b257beec642f3448ad2bfa7f84ac4448a8b2129e" "1c60697df0f10da379411bb7cbd79002f9714883" "99d4f98c0151c7e25437bb625f114bde347170d5")
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
	"build hal/usb include tools"
	"common-mk"
)
PLATFORM_GYP_FILE="tools/generate_camera_profile.gyp"

inherit cros-camera cros-workon

DESCRIPTION="Runtime detect the number of cameras on device to generate
corresponding media_profiles.xml."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	media-libs/cros-camera-libcamera_timezone"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	dobin "${OUT}/generate_camera_profile"
}
