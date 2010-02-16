# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

DESCRIPTION="Google's C++ mocking framework."
HOMEPAGE="http://code.google.com/p/googlemock/"
SRC_URI="http://googlemock.googlecode.com/files/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND=">=dev-cpp/gtest-1.4.0"

src_configure() {
	econf --with-gtest="${ROOT}/usr" || die "gmock configure failed."
}

src_compile() {
	emake GTEST_LDFLAGS= || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
