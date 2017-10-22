# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="e4ee3d41c13e63e1345332fbf5fce4ed81dc5b92"
CROS_WORKON_TREE="a18afeb7b130c8f1e2442abb79747d74ec1f3e32"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC USB camera HAL v3."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan test"
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
	media-libs/arc-camera3-libcamera_timezone
	media-libs/libyuv
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} camera_hal_usb
	use test && emake BASE_VER=${LIBCHROME_VERS} hal_usb_test
}

src_install() {
	dolib.so hal/usb/camera_hal.so
}

src_test() {
	if use x86 || use amd64; then
		./hal/usb/unittest/image_processor_unittest || \
			die "image_processor unit tests failed!"
	fi
}