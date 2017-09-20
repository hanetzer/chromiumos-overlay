# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="8dd552f647f21f2f0f56c37b15756627754b46a8"
CROS_WORKON_TREE="0192e1233e84dfa87930b3ff3f05da9e4792962b"
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
	media-libs/libyuv
	virtual/pkgconfig"

src_compile() {
	asan-setup-env
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} camera_hal_usb
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
