# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3
CROS_WORKON_PROJECT="chromiumos/third_party/xf86-input-cmt"

XORG_EAUTORECONF="yes"
BASE_INDIVIDUAL_URI=""
inherit xorg-2 cros-workon

DESCRIPTION="Chromium OS multitouch input driver for Xorg X server."
CROS_WORKON_LOCALNAME="xf86-input-cmt"

KEYWORDS="~arm ~x86"
LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND="x11-base/xorg-server
	 x11-libs/mtdev"
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
