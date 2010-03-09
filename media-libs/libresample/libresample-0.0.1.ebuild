# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="This is the resampling library. See README.txt for details."
HOMEPAGE=""
SRC_URI=""
LICENSE="LGPL"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

src_unpack() {
	local thirdparty="${CHROMEOS_ROOT}/src/third_party/"
	elog "Using thirdparty: $thirdparty"
	mkdir -p "${S}"
	cp -a "${thirdparty}"/libresample/* "${S}" || die
}

src_compile() {
	tc-getCC
	tc-getAR
	emake -j1 || die "emake failed"
}

src_install() {
	insinto /usr/lib
	insopts -m0755
	doins "${S}/libresample.a"
        insinto /usr/include/libresample
	doins "${S}/include/"*.h || die "include install failed"

}
