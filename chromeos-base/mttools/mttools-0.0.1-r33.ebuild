# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="00b561b31b77a6e7ccaf7eea2d4c1f052926a78f"
CROS_WORKON_TREE="f469f258f319b12806d4f399109a9cb68ae212c9"
CROS_WORKON_PROJECT="chromiumos/platform/mttools"

inherit cros-workon

DESCRIPTION="Chromium OS multitouch utilities"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/gestures
	app-misc/utouch-evemu
	chromeos-base/libevdev"

DEPEND=${RDEPEND}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	# install to autotest deps directory for dependency
	emake DESTDIR="${D}/usr/local/autotest/client/deps/touchpad-tests/framework" install
}
