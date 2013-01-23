# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="d5aa52f119cf4e202f438695265d4139a9db9a7b"
CROS_WORKON_TREE="f14eb09a56b00fe011bab210108ef530bc39b855"
CROS_WORKON_PROJECT="chromiumos/platform/touchpad-tests"

XORG_EAUTORECONF="yes"
BASE_INDIVIDUAL_URI=""
inherit autotools-utils cros-workon

DESCRIPTION="Chromium OS multitouch driver regression tests."
CROS_WORKON_LOCALNAME="../platform/touchpad-tests"

KEYWORDS="arm amd64 x86"
LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND="chromeos-base/gestures
	chromeos-base/libevdev
	app-misc/utouch-evemu
	x11-proto/inputproto"

DEPEND=${RDEPEND}

DOCS=""

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	emake all
}

src_install() {
	# install to autotest deps directory for dependency
	emake DESTDIR="${D}/usr/local/autotest/client/deps/touchpad-tests" install
}
