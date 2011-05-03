# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/mtdev"

inherit autotools cros-workon

DESCRIPTION="mtdev library for multitouch"
HOMEPAGE="http://bitmath.org/code/mtdev/"
KEYWORDS="~arm ~x86"
LICENSE="MIT"
SLOT="0"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf || die
}

src_configure() {
	econf --disable-static \
		--disable-maintainer-mode
}

src_install() {
	emake DESTDIR="${D}" install || die
	rm -f "${D}/usr/lib/libmtdev.la"
}
