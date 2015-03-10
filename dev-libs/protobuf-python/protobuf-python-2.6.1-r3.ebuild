# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/protobuf/protobuf-2.5.0-r2.ebuild,v 1.7 2015/01/26 09:37:24 ago Exp $

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
SLOT="0/9" # subslot = soname major version
KEYWORDS="*"

IUSE=""

CDEPEND="${PYTHON_DEPS}
	!dev-libs/protobuf[python]"
DEPEND="${CDEPEND}
	dev-python/google-apputils[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	"
RDEPEND="${CDEPEND}
	~dev-libs/protobuf-${PV}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	pushd python >/dev/null
	distutils-r1_src_prepare
	popd >/dev/null
}

src_configure() {
	local myeconfargs=( )

	if tc-is-cross-compiler; then
		# The build system wants `protoc` when building, so we need a copy that
		# runs on the host.  This is more hermetic than relying on the version
		# installed in the host being the exact same version.
		mkdir -p "${WORKDIR}"/build || die
		pushd "${WORKDIR}"/build >/dev/null
		ECONF_SOURCE=${S} econf_build "${myeconfargs[@]}"
		myeconfargs+=( --with-protoc="${PWD}"/src/protoc )
		popd >/dev/null
	fi

	distutils-r1_src_configure
}

src_compile() {
	if tc-is-cross-compiler; then
		emake -C "${WORKDIR}"/build/src protoc
	fi

	pushd python >/dev/null
	PROTOC="${WORKDIR}"/build/src/protoc distutils-r1_src_compile
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
}
