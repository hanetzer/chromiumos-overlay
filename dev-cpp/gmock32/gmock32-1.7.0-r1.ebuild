# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gmock/gmock-1.7.0-r1.ebuild,v 1.5 2014/10/25 14:07:06 maekke Exp $

EAPI="4"

PYTHON_COMPAT=( python2_7 )

inherit eutils libtool python-any-r1 cros-au

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
DEPEND="${RDEPEND}
	test? ( ${PYTHON_DEPS} )
	app-arch/unzip"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	# Stub to disable python_setup running when USE=-test.
	# We'll handle it down in src_test ourselves.
	:
}

src_unpack() {
	default
	# make sure we always use the system one
	rm -r "${S}"/gtest/{Makefile,configure}* || die
}

src_prepare() {
	sed -i -r \
		-e '/^install-(data|exec)-local:/s|^.*$|&\ndisabled-&|' \
		Makefile.in
	elibtoolize
}

src_configure() {
	board_setup_32bit_au_env
	ECONF_SOURCE=${S} econf --disable-shared --enable-static
	board_teardown_32bit_au_env
}

src_test() {
	board_setup_32bit_au_env
	python_setup
	emake check
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
