# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("4ce1fef68d5b79bbf40244bcf4960a8c52bee9c2" "e00f7c3bc1df3facd1751e94dda150e94723ab3e")
CROS_WORKON_TREE=("6589055d0d41e7fc58d42616ba5075408d810f7d" "c925dff34bb7f1910583df0f4b80358b3738665a" "0f93a06541157726fd56da5dc65eb9f25b19756e" "94a1336ddfc584b23df58564be093463f801d558")
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
	"build common/v4l2_device include"
	"common-mk"
)
PLATFORM_GYP_FILE="common/v4l2_device/libcamera_v4l2_device.gyp"

inherit cros-camera cros-workon

DESCRIPTION="Chrome OS camera HAL v3 V4L2 device utility."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=""

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	dolib.so "${OUT}/lib/libcamera_v4l2_device.so"

	cros-camera_doheader include/cros-camera/v4l2_device.h

	cros-camera_dopc common/v4l2_device/libcamera_v4l2_device.pc.template
}
