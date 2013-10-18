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
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
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
	use pnm2png &&
		emake -C contrib/pngminus -f makefile.std pnm2png CC=$(tc-getCC)
}

src_install() {
	emake DESTDIR="${D}" install
	use pnm2png && dobin contrib/pngminus/pnm2png
}
