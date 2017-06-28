# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c1b31aa2633181ae0159ea63fe85c2f0845dbcbd"
CROS_WORKON_TREE="a0eff25cd70a60805b0f8a29d4bd6e0c6b4f43a5"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC USB camera HAL v3."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"
RDEPEND="
	chromeos-base/libbrillo
	media-libs/libexif"

DEPEND="${RDEPEND}
	media-libs/arc-camera3-android-headers
	media-libs/arc-camera3-libcamera_client
	media-libs/arc-camera3-libcamera_jpeg
	media-libs/arc-camera3-libcamera_metadata
	media-libs/arc-camera3-libsync
	media-libs/libyuv
	virtual/pkgconfig"

src_compile() {
	asan-setup-env
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} camera_hal_usb
}

src_install() {
	dolib.so hal/usb/camera_hal.so
}
