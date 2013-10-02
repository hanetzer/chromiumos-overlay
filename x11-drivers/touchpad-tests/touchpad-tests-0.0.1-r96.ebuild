# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0b8d80eb1909d7e31fb738e48aec851f0a444f54"
CROS_WORKON_TREE="1a1258f8f1b72618d1f9445a7fa79b133eee4e42"
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
