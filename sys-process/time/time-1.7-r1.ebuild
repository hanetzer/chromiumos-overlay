# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/time/time-1.7-r1.ebuild,v 1.4 2006/11/13 15:14:41 swegener Exp $

WANT_AUTOMAKE="latest"
WANT_AUTOCONF="latest"
inherit eutils autotools

DESCRIPTION="displays info about resources used by a program"
HOMEPAGE="http://www.gnu.org/directory/time.html"
SRC_URI="mirror://gnu/time/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-build.patch
	epatch "${FILESDIR}"/${PV}-info-dir-entry.patch
	epatch "${FILESDIR}"/${P}-wait3.patch
	eautoreconf
}

src_compile() {   
  tc-export CC
  econf || die
  emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog README AUTHORS NEWS
}
