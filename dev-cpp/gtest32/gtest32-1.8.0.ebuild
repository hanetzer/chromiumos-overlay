# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

AUTOTOOLS_AUTORECONF=1
AUTOTOOLS_IN_SOURCE_BUILD=1
# Python is required for tests and some build tasks.
PYTHON_COMPAT=( python2_7 )

inherit autotools cros-au eutils python-any-r1

MY_PN="${PN%32}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Google C++ Testing Framework"
HOMEPAGE="http://github.com/google/googletest/"
SRC_URI="https://github.com/google/googletest/archive/release-${PV}.tar.gz -> googletest-release-${PV}.tar.gz"
SRC_URI="https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/googletest-release-${PV}.tar.gz"
S="${WORKDIR}/googletest-release-${PV}/googletest"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au"
REQUIRED_USE="32bit_au"
RESTRICT="test"

DEPEND="${PYTHON_DEPS}"
RDEPEND=""

PATCHES=(
	"${FILESDIR}/configure-fix-pthread-linking.patch" #371647
	"${FILESDIR}/${MY_P}-makefile-am.patch"
)

src_prepare() {
	default
	eautoreconf
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
