# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.45.ebuild,v 1.4 2011/07/12 12:39:02 tomka Exp $

# This ebuild uses compiles and installs everything from the package, rather
# than just libpng12.so.0 as upstream does.  The additional installed files
# are needed by other packages.  The x11-libs/cairo package is one example.

EAPI=4

inherit autotools eutils multilib libtool

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ~m68k ~mips ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib
	!=media-libs/libpng-1.2*:0"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

pkg_setup() {
	if [[ -e ${EROOT}/usr/$(get_libdir)/libpng12.so.0 ]] ; then
		rm -f "${EROOT}"/usr/$(get_libdir)/libpng12.so.0
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-build.patch
	eautoreconf
	elibtoolize
}

src_configure() {
	econf --disable-static
}
