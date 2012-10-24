# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="06a7508187ec38e25fe85e93fb1a38d112a764be"
CROS_WORKON_TREE="91ac344e1594d07fd75d60915fcf7ff1979acdae"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="../platform/ec"

inherit cros-workon toolchain-funcs cros-board

DESCRIPTION="Chrome OS EC Utility"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

set_board() {
	export BOARD=$(get_current_board_with_variant)
	if [[ ! -d board/${BOARD} ]] ; then
		ewarn "${BOARD} does not use Chrome EC. Setting BOARD=bds."
		BOARD=bds
	fi
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
	export HOSTCC="$CC"
	set_board
	emake utils
}

src_install() {
	set_board
	dosbin "build/$BOARD/util/ectool"
	dosbin "build/$BOARD/util/stm32mon"
}
