# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="64a34a339ab2dc4c2261c2f62c5a55771b9ffac7"
CROS_WORKON_TREE="9b6ff14f82cd311311e141066f01c386c2d73936"
CROS_WORKON_PROJECT="chromiumos/third_party/hdctools"

SUPPORT_PYTHON_ABIS="1"

inherit cros-workon distutils toolchain-funcs multilib

DESCRIPTION="Software to communicate with servo/miniservo debug boards"
HOMEPAGE=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=">=dev-embedded/libftdi-0.18
	dev-libs/libusb
	dev-python/numpy
	dev-python/pexpect
	dev-python/pyserial
	dev-python/pyusb"
DEPEND="${RDEPEND}
	app-text/htmltidy"

src_compile() {
	tc-export CC PKG_CONFIG
	emake || die
	distutils_src_compile
}

src_install() {
	emake DESTDIR="${D}" LIBDIR=/usr/$(get_libdir) install || die
	distutils_src_install
}
