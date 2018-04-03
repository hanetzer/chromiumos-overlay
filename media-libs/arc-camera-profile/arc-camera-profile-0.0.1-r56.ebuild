# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="1e5befcb09442edf0ca420f6c8b02f382a4579f0"
CROS_WORKON_TREE="2f27da4d730a756e11b762873396cbf0345bbe5c"
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
