# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gmock/gmock-1.6.0.ebuild,v 1.6 2012/08/24 09:23:27 xmw Exp $

EAPI="4"

inherit eutils libtool cros-au

MY_PN=${PN%32}
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Google's C++ mocking framework"
HOMEPAGE="http://code.google.com/p/googlemock/"
SRC_URI="http://googlemock.googlecode.com/files/${MY_P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au"
REQUIRED_USE="32bit_au"
RESTRICT="test"

RDEPEND="=dev-cpp/gtest32-${PV}*"
DEPEND="app-arch/unzip
	${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	default
	# make sure we always use the system one
	rm -r "${S}"/gtest/{Makefile,configure}* || die
}

src_prepare() {
	sed -i -r \
		-e '/^install-(data|exec)-local:/s|^.*$|&\ndisabled-&|' \
		Makefile.in
        epatch "${FILESDIR}/1.6.0-fix_mutex.patch" || die
	elibtoolize
}

src_configure() {
	board_setup_32bit_au_env
	econf --disable-shared --enable-static
	board_teardown_32bit_au_env
}

src_compile() {
	board_setup_32bit_au_env
	default
	board_teardown_32bit_au_env
}

src_install() {
	board_setup_32bit_au_env
	dolib.a lib/.libs/libgmock{,_main}.a
	board_teardown_32bit_au_env
}
