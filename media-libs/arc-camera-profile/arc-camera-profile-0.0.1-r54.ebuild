# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="266a72e3439d530f6be2009f7e8097456ff73bad"
CROS_WORKON_TREE="12694cb38d9d0d2c39dffbfe95cf15832a32d3e7"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Runtime detect the number of cameras on device to generate
corresponding media_profiles.xml."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="
	chromeos-base/libbrillo"

DEPEND="${RDEPEND}
	media-libs/cros-camera-libcamera_timezone
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} camera_profile
}

src_install() {
	dobin tools/generate_camera_profile
}
