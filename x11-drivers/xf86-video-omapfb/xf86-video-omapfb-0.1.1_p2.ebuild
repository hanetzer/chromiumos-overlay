# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit eutils toolchain-funcs autotools

DESCRIPTION="X.Org driver for TI OMAP framebuffers"
IUSE="+neon"
KEYWORDS="arm"
LICENSE="as-is"
SLOT="0"
SRC_URI="http://build.chromium.org/mirror/chromiumos/other/${P}.tar.gz"

RDEPEND="x11-base/xorg-server"
DEPEND="${RDEPEND}
	x11-proto/renderproto"

src_prepare() {
	epatch "${FILESDIR}/${P}-configure.patch" || die
	eautoreconf || die
}

src_configure() {
	econf --enable-maintainer-mode "$(use_enable_neon)" || die
}

src_install() {
	insinto /usr/lib/xorg/modules/drivers
	doins "${S}"/src/.libs/omapfb_drv.so
}
