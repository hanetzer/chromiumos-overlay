# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="9d9fb986f7e3f677d8c491feb55295d413f8e9f1"
CROS_WORKON_TREE="fd89c4cc4a8b3d3a77ece0205651a0e24511db13"
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
