# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c27d5cf80fb2a005c28f93545d1f2bc133cf7981"
CROS_WORKON_TREE="11163cf60d3899f20f62e6dd093c1c8a4cb9f493"
CROS_WORKON_PROJECT="chromiumos/platform/touchpad-tests"
CROS_WORKON_LOCALNAME="../platform/touchpad-tests"

inherit cros-workon

DESCRIPTION="Chromium OS multitouch driver regression tests"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/gestures
	chromeos-base/libevdev
	app-misc/utouch-evemu
	chromeos-base/xorg-conf
	x11-proto/inputproto"
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
	emake DESTDIR="${D}/usr/local/autotest/client/deps/touchpad-tests" install
}
