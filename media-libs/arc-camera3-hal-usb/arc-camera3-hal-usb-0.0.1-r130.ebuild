# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="8305a485d5206e6d38947dfca44ab832f37ca575"
CROS_WORKON_TREE="d973df5fc42759256ed03e0e14deba037a255a98"
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
	!media-libs/arc-camera3-libsync
	media-libs/arc-camera3-libcamera_exif
	media-libs/arc-camera3-libcbm
	media-libs/libsync"

DEPEND="${RDEPEND}
	media-libs/arc-camera3-android-headers
	media-libs/arc-camera3-libcamera_client
	media-libs/arc-camera3-libcamera_jpeg
	media-libs/arc-camera3-libcamera_metadata
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
