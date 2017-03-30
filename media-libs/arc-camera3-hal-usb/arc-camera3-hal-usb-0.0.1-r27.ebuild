# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="12b27e11e22c1fc4071eac0ab08230ce1fdd03eb"
CROS_WORKON_TREE="550e4e611778379c839e7b2fdd85b46b963b41ff"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC USB camera HAL v3."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	chromeos-base/libbrillo
	media-libs/libexif
	media-libs/libyuv
	virtual/jpeg:0"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_compile() {
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} camera_hal_usb
}

src_install() {
	dolib.so hal/usb/camera_hal.so
}
