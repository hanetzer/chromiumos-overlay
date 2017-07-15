# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="febb4381c1b8d2730e13d8e8605e178da4413919"
CROS_WORKON_TREE="d93edeeea01f9f970193f8a6ef0fd72661ff0268"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"
PYTHON_COMPAT=( python2_7 )

inherit cros-workon distutils-r1

DESCRIPTION="Host development utilities for Chromium OS EC"
HOMEPAGE="https://www.chromium.org/chromium-os/ec-development"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
ISUE=""

RDEPEND="
	app-mobilephone/dfu-util
	sys-apps/flashrom
	"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

set_board() {
	# No need to be board specific, no tools below build code that is
	# EC specific. bds works for forst side compilation.
	export BOARD="bds"
}

src_configure() {
	cros-workon_src_configure
	distutils-r1_src_configure
}

src_compile() {
	tc-export AR CC RANLIB
	# In platform/ec Makefile, it uses "CC" to specify target chipset and
	# "HOSTCC" to compile the utility program because it assumes developers
	# want to run the utility from same host (build machine).
	# In this ebuild file, we only build utility
	# and we may want to build it so it can
	# be executed on target devices (i.e., arm/x86/amd64), not the build
	# host (BUILDCC, amd64). So we need to override HOSTCC by target "CC".
	export HOSTCC="${CC}"
	set_board
	emake utils-host
	distutils-r1_src_compile
}

src_install() {
	set_board
	dobin "build/${BOARD}/util/stm32mon"
	dobin "build/${BOARD}/util/ec_parse_panicinfo"

	dobin "util/flash_ec"
	insinto /usr/bin/lib
	doins util/openocd/*

	distutils-r1_src_install
}
