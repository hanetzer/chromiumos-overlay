# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="1e352146ba25dfe2d7bac5dbd57a5f4be7b08091"
CROS_WORKON_TREE="f6da3a8eb80fc1e3fa881d7402a7b22cb9b57e6c"

EAPI=2
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
