# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="67c72d33891c4db6cb30c5557db5375b3ef8dc71"
CROS_WORKON_TREE="32fff61db356bb5553af70ed60a3e14498093da8"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Runtime detect the number of cameras on device to generate
corresponding media_profiles.xml.xml."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="
	chromeos-base/libbrillo"

DEPEND="${RDEPEND}
	media-libs/arc-camera3-libcamera_timezone
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
