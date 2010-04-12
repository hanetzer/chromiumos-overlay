# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils flag-o-matic toolchain-funcs

EAPI="2"

DESCRIPTION="Make a hexdump or do the reverse"
HOMEPAGE="http://ftp.uni-erlangen.de/pub/utilities/etc/?order=s"
SRC_URI="http://ftp.uni-erlangen.de/pub/utilities/etc/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare () {
	sed -i "s|-O|$CFLAGS|g" Makefile || die "sed failed"
}

src_compile() {      
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	exeinto "/bin" # Has to be /bin rather than /usr/bin due to conflict with vim
	doexe xxd
}
