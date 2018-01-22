# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="a8d6ae7d131e57fc1865210cae4ae0a2047c561c"
CROS_WORKON_TREE="2bbcd1a295e18582825e84d9a84e3062fba2db9a"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera service. The service is in charge of accessing camera
device. It uses linux domain socket (/run/camera/camera.sock) to build a
synchronous channel."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="!chromeos-base/arc-camera-service"

DEPEND="${RDEPEND}
	chromeos-base/libbrillo
	chromeos-base/libmojo
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake -C hal/usb_v1 arc_camera_service
}

src_install() {
	dobin arc_camera_service
}
