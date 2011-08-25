# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit autotools

DESCRIPTION="Test program for capturing input device events"
HOMEPAGE="http://cgit.freedesktop.org/evtest/"
SRC_URI="http://cgit.freedesktop.org/evtest/snapshot/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"

DEPEND="app-text/asciidoc
        app-text/xmlto"

RDEPEND="dev-libs/libxml2
         dev-libs/libxslt"

src_prepare() {
        eautoreconf
}
