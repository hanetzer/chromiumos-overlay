# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="edd84898b8c91497c5437ba0772965e0f6112063"
CROS_WORKON_TREE="ca18750dd9a63dff1537668b81db4014325344fc"
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
