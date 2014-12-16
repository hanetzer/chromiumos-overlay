# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e19f0927be9fc339456e1c589fd41c4f033d135b"
CROS_WORKON_TREE="8367a15ef734f70db1b73ba2e833296fd9b72f5a"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"

inherit cros-workon

DESCRIPTION="Host development utilities for Chromium OS EC"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
ISUE=""

RDEPEND="sys-apps/flashrom"
DEPEND=""

set_board() {
	# No need to be board specific, no tools below build code that is
	# EC specific. bds works for forst side compilation.
	export BOARD="bds"
}

src_configure() {
	cros-workon_src_configure
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
}

src_install() {
	set_board
	dobin "build/${BOARD}/util/stm32mon"

	dobin "util/flash_ec"
	insinto /usr/bin/lib
	doins chip/lm4/openocd/*
}
