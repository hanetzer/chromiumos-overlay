# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.47.ebuild,v 1.2 2012/02/20 11:56:37 ssuominen Exp $

# This ebuild uses compiles and installs everything from the package, rather
# than just libpng12.so.0 as upstream does.  The additional installed files
# are needed by other packages.  The x11-libs/cairo package is one example.

EAPI=4

inherit eutils libtool multilib toolchain-funcs

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="*"
IUSE="pnm2png static-libs"

RDEPEND="sys-libs/zlib
	!=media-libs/libpng-1.2*:0"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

src_prepare() {
	epatch "${FILESDIR}"/${P}-pnm2png-eof.patch
	epatch "${FILESDIR}"/${P}-pnm2png-comment-line.patch
	epatch "${FILESDIR}"/${P}-pnm2png-pbm.patch
	epatch "${FILESDIR}"/${P}-pnm2png-truncate-get-token.patch
	elibtoolize
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_compile() {
	emake
	if use pnm2png; then
		pushd contrib/pngminus > /dev/null
		../../libtool --mode=compile $(tc-getCC) ${CFLAGS} ${CPPFLAGS} \
			-I../.. -c pnm2png.c || die
		../../libtool --mode=link $(tc-getCC) ${CFLAGS} ${LDFLAGS} \
			pnm2png.lo -o pnm2png ../../libpng.la || die
		popd > /dev/null
	fi
}

src_install() {
	emake DESTDIR="${D}" install
	if use pnm2png; then
		./libtool --mode=install install -D contrib/pngminus/pnm2png \
			"${ED}/usr/bin/pnm2png" || die
	fi
}
