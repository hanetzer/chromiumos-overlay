# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/protobuf/protobuf-2.3.0-r1.ebuild,v 1.5 2011/03/16 18:00:10 xarthisius Exp $

# This package was split out of dev-libs/protobuf as that ebuild installed the
# python bits in the stateful partition under /usr/local to be put back into
# python's site-packages directory when building a dev image. Instead here
# we install directly into site-packages.

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )
DISTUTILS_OPTIONAL=1

inherit autotools distutils-r1 toolchain-funcs

MY_P="protobuf-${PV}"
DESCRIPTION="Google's Protocol Buffers Python Module Installation"
HOMEPAGE="http://code.google.com/p/protobuf/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${MY_P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

CDEPEND="${PYTHON_DEPS}
	!dev-libs/protobuf[python]"
DEPEND="${CDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	"
RDEPEND="${CDEPEND}
	~dev-libs/protobuf-${PV}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	distutils-r1_src_prepare
}

src_compile() {
	pushd python >/dev/null
	distutils-r1_src_compile
	popd >/dev/null
}

src_test() {
	pushd python
	distutils-r1_src_test
	popd
}

src_install() {
	pushd python
	distutils-r1_src_install
	popd
	# HACK ALERT: upstream setup.py forgets to install google/__init__.py,
	# hack now, fix properly later.
	pushd "${D}"
	local whereto="$(find . -name 'site-packages')"
	popd
	insinto "${whereto/./}"/google/
	doins "${S}"/python/google/__init__.py
}
