# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3
CROS_WORKON_COMMIT="13d11a7589fe07df0de7b0ab191682599147335a"
XORG_EAUTORECONF="yes"
BASE_INDIVIDUAL_URI=""
inherit linux-info xorg-2 cros-workon

DESCRIPTION="Multitouch Xorg Xinput driver."
HOMEPAGE="http://bitmath.org/code/multitouch/"
CROS_WORKON_LOCALNAME="multitouch"
CROS_WORKON_PROJECT="multitouch"

KEYWORDS="arm x86"
LICENSE="GPL"
SLOT="0"
IUSE=""

RDEPEND="x11-base/xorg-server
	 x11-libs/mtdev
	 x11-libs/pixman"
DEPEND="${RDEPEND}
	x11-proto/inputproto"

src_prepare() {
	xorg-2_src_prepare
}

src_install() {
	DOCS="README" xorg-2_src_install
}

pkg_postinst() {
	xorg-2_pkg_postinst
}
