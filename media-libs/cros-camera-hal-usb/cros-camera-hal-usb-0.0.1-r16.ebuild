# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="0216e959f16f4173784f0336c542975e6c3fa68c"
CROS_WORKON_TREE="b34f0c73590d1c819f389ccd5d986a9d86207050"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Chrome OS USB camera HAL v3."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan test"
RDEPEND="
	chromeos-base/libbrillo
	!media-libs/arc-camera3-hal-usb
	media-libs/cros-camera-libcamera_exif
	media-libs/cros-camera-libcbm
	media-libs/libsync"

DEPEND="${RDEPEND}
	media-libs/cros-camera-android-headers
	media-libs/cros-camera-libcamera_client
	media-libs/cros-camera-libcamera_common
	media-libs/cros-camera-libcamera_jpeg
	media-libs/cros-camera-libcamera_metadata
	media-libs/cros-camera-libcamera_timezone
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
	insinto "/usr/$(get_libdir)/camera_hal"
	newins hal/usb/camera_hal.so usb.so
}

src_test() {
	if use x86 || use amd64; then
		./hal/usb/unittest/image_processor_unittest || \
			die "image_processor unit tests failed!"
	fi
}