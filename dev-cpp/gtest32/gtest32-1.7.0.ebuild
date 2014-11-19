# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gtest/gtest-1.7.0.ebuild,v 1.6 2014/08/21 11:29:34 armin76 Exp $

EAPI="5"

AUTOTOOLS_AUTORECONF=1
AUTOTOOLS_IN_SOURCE_BUILD=1
# Python is required for tests and some build tasks.
PYTHON_COMPAT=( python{2_6,2_7} )

inherit eutils python-any-r1 cros-au

MY_PN=${PN%32}
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Google C++ Testing Framework"
HOMEPAGE="http://code.google.com/p/googletest/"
SRC_URI="http://googletest.googlecode.com/files/${MY_P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au"
RESTRICT="test"

DEPEND="app-arch/unzip
	${PYTHON_DEPS}"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/configure-fix-pthread-linking.patch" #371647
)

src_prepare() {
	sed -i -e "s|/tmp|${T}|g" test/gtest-filepath_test.cc || die
	sed -i -r \
		-e '/^install-(data|exec)-local:/s|^.*$|&\ndisabled-&|' \
		Makefile.am || die
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

src_test() {
	board_setup_32bit_au_env
	# explicitly use parallel make
	emake check || die
	board_teardown_32bit_au_env
}

src_install() {
	board_setup_32bit_au_env
	dolib.a lib/.libs/libgtest{,_main}.a
	board_teardown_32bit_au_env
}
