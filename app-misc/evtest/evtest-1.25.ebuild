# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit autotools

DESCRIPTION="Test program for capturing input device events"
HOMEPAGE="http://people.freedesktop.org/~whot/evtest/"
SRC_URI="http://cgit.freedesktop.org/~whot/evtest/snapshot/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"

DEPEND="dev-libs/libxml2
        dev-libs/libxslt
        app-text/xmlto
        app-text/asciidoc"

RDEPEND="dev-libs/libxml2"

src_prepare() {
        eautoreconf || die "Autoreconf failed"
}

src_install() {
        emake DESTDIR="${D}" install || die "Install failed"
}
