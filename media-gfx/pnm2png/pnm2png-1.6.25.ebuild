# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

MY_PN="libpng"
MY_P="${MY_PN}-${PV}"

inherit toolchain-funcs eutils

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.xz"

LICENSE="libpng"
SLOT="0/16"
KEYWORDS="*"
IUSE=""

RDEPEND="media-libs/libpng:0=[-pnm2png(-)]"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

S="${WORKDIR}/${MY_P}/contrib/pngminus"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.2.56-pnm2png-truncate-get-token.patch
}

e() {
	echo "$@"
	"$@"
}

src_compile() {
	e $(tc-getCC) ${CFLAGS} ${CPPFLAGS} \
		$($(tc-getPKG_CONFIG) libpng --cflags --libs) ${LDFLAGS} \
		pnm2png.c -o pnm2png
}

src_install() {
	dobin pnm2png
}
