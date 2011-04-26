# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit base autotools

DESCRIPTION="Test program for capturing input device events"
HOMEPAGE="http://cgit.freedesktop.org/evtest/"
SRC_URI="http://cgit.freedesktop.org/evtest/snapshot/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"

DEPEND="dev-libs/libxml2
        dev-libs/libxslt
        app-text/xmlto
        app-text/asciidoc"

RDEPEND="dev-libs/libxml2"

RESTRICT="mirror"

UPSTREAMED_PATCHES=(
	"${FILESDIR}/1.27-0001-Add-support-for-EV_SW.patch"
)

PATCHES=(
	"${UPSTREAMED_PATCHES[@]}"
)

src_prepare() {
        base_src_prepare
        eautoreconf || die "Autoreconf failed"
}
