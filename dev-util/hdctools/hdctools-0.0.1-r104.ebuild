# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="0ad79828bb0d9f5ecb19e038cac56dbb4d625fca"
CROS_WORKON_TREE="cbccf4922fcef6b202969ba0fe4f6f8c0d7f085b"

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
	# distutils takes care of installing servod, and doesn't like
	# it when something else already installed it ...
	rm -f "${D}"/usr/bin/servod
	distutils_src_install
}
