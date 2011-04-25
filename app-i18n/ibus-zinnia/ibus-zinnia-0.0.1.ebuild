# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils flag-o-matic

DESCRIPTION="Zinnia hand-writing engine"
HOMEPAGE="http://github.com/yusukes/ibus-zinnia"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"
#RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND=">=app-i18n/ibus-1.3.99
	 app-i18n/zinnia
	 app-i18n/tegaki-zinnia-japanese-light"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/gettext-0.16.1"

src_configure() {
    append-cflags -Wall -Werror
    econf || die
}

src_install() {
    emake DESTDIR="${D}" install || die
    dodoc AUTHORS ChangeLog NEWS README
}
