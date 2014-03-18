# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="2446d337037e964c552d69cf92ed3ba4ad70c0b1"
CROS_WORKON_TREE="6052f339502799c69d10efdb425b03de64b52953"
CROS_WORKON_PROJECT="chromiumos/third_party/hdctools"

SUPPORT_PYTHON_ABIS="1"

inherit cros-workon distutils toolchain-funcs multilib

DESCRIPTION="Software to communicate with servo/miniservo debug boards"
HOMEPAGE=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

RDEPEND=">=dev-embedded/libftdi-0.18
	dev-libs/libusb
	dev-python/numpy
	dev-python/pexpect
	dev-python/pyserial
	dev-python/pyusb"
DEPEND="${RDEPEND}
	app-text/htmltidy"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CC PKG_CONFIG
	local makeargs=( $(usex cros_host '' EXTRA_DIRS=chromeos) )
	emake "${makeargs[@]}" || die
	distutils_src_compile
}

src_install() {
	local makeargs=(
		$(usex cros_host '' EXTRA_DIRS=chromeos)
		DESTDIR="${D}" LIBDIR=/usr/$(get_libdir)
		install
	)
	emake "${makeargs[@]}" || die
	distutils_src_install
}
