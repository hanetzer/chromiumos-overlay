# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="e505b8dd2c617d8fac4bbe51996ddb7822c73d61"

DESCRIPTION="Software to communicate with servo/miniservo debug boards"
HOMEPAGE=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

inherit cros-workon distutils

RDEPEND=">=dev-embedded/libftdi-0.18
	dev-libs/libusb"

DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC PKG_CONFIG 
	emake || die "emake compile failed."
	distutils_src_compile || die "distutils compile failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	distutils_src_install || die "distutils install failed"
}
