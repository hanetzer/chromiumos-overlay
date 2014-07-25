# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.51.ebuild,v 1.3 2014/06/09 23:28:13 vapier Exp $

EAPI=5

# This ebuild compiles and installs everything from the package, rather
# than just libpng12.so.0 as upstream does. The additional installed files
# are needed by other packages. The x11-libs/cairo package is one example.

inherit libtool multilib-minimal

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="libpng"
SLOT="0/12"
KEYWORDS="*"
IUSE="pnm2png static-libs"

RDEPEND=">=sys-libs/zlib-1.2.8-r1:=[${MULTILIB_USEDEP}]
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-baselibs-20130224-r3
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)] )"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

src_prepare() {
	epatch "${FILESDIR}"/${P}-pnm2png-eof.patch
	epatch "${FILESDIR}"/${P}-pnm2png-comment-line.patch
	epatch "${FILESDIR}"/${P}-pnm2png-pbm.patch
	epatch "${FILESDIR}"/${P}-pnm2png-truncate-get-token.patch
	elibtoolize
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf $(use_enable static-libs static)
}

multilib_src_compile() {
	emake
	if use pnm2png; then
		pushd "${S}"/contrib/pngminus > /dev/null
		"${BUILD_DIR}"/libtool --mode=compile $(tc-getCC) ${CFLAGS} \
			${CPPFLAGS}  -I../.. -c pnm2png.c || die
		"${BUILD_DIR}"/libtool --mode=link $(tc-getCC) ${CFLAGS} ${LDFLAGS} \
			pnm2png.lo -o "${BUILD_DIR}"/pnm2png "${BUILD_DIR}"/libpng.la || die
		popd > /dev/null
	fi
}

multilib_src_install() {
	emake DESTDIR="${D}" install
	if use pnm2png; then
		./libtool --mode=install install -D pnm2png \
			"${ED}/usr/bin/pnm2png" || die
	fi
}
