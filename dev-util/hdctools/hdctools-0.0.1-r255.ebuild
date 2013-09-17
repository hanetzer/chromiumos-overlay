# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="89f09829f3b18e2d4722e44ac1f6125ebf15f16c"
CROS_WORKON_TREE="864894a44f6b041c9b2af8115e478d5dc674af7f"
CROS_WORKON_PROJECT="chromiumos/third_party/hdctools"

SUPPORT_PYTHON_ABIS="1"

inherit cros-workon distutils toolchain-funcs multilib

DESCRIPTION="Software to communicate with servo/miniservo debug boards"
HOMEPAGE=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND=">=dev-embedded/libftdi-0.18
	dev-libs/libusb
	dev-python/numpy
	dev-python/pexpect
	dev-python/pyserial
	dev-python/pyusb"
DEPEND="${RDEPEND}
	app-text/htmltidy"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	tc-export CC PKG_CONFIG
	emake
	distutils_src_compile
}

src_install() {
	emake DESTDIR="${D}" LIBDIR=/usr/$(get_libdir) install
	distutils_src_install
}
