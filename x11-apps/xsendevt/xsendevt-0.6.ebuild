# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils

DESCRIPTION="X11 tool to send events"
HOMEPAGE="http://xsendevt.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXt"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-const.patch
	epatch "${FILESDIR}"/${P}-includes.patch
}