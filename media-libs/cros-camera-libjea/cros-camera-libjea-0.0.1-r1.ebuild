# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("ca305d51437dfaf065ce054fb903f4a0c3a28d44" "5f886f904ccc6e3471d2f39b4f73d0f4eb916a6c")
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
PLATFORM_GYP_FILE="common/jpeg/libjea.gyp"

inherit cros-camera cros-workon

DESCRIPTION="Library for using JPEG Encode Accelerator in Chrome"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="media-libs/cros-camera-libcamera_common"

DEPEND="${RDEPEND}
	media-libs/cros-camera-libcamera_ipc
	virtual/pkgconfig"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	dolib.a "${OUT}/libjea.pic.a"

	cros-camera_doheader include/cros-camera/jpeg_encode_accelerator.h

	cros-camera_dopc common/jpeg/libjea.pc.template
}
