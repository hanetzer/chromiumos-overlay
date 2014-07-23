# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="054c9fe6a6b32098f5fa881d49c6f43707d8d042"
CROS_WORKON_TREE="542872426ba9b498e00aa87248aadb849b18efad"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"

inherit cros-workon toolchain-funcs cros-board

DESCRIPTION="Chrome OS EC Utility"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="dev-embedded/libftdi"
DEPEND="${RDEPEND}"

set_board() {
	export BOARD=$(get_current_board_with_variant)
	if [[ ! -d board/${BOARD} ]] ; then
		ewarn "${BOARD} does not use Chrome EC. Setting BOARD=bds."
		BOARD=bds
	fi
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
	export HOSTCC="$CC"
	set_board
	emake utils
}

src_install() {
	set_board
	dosbin "build/$BOARD/util/ectool"
	if [[ -d board/${BOARD}/userspace/etc/init ]] ; then
		insinto /etc/init
		doins board/${BOARD}/userspace/etc/init/*.conf
	fi
	if [[ -d board/${BOARD}/userspace/usr/share/ec ]] ; then
		insinto /usr/share/ec
		doins board/${BOARD}/userspace/usr/share/ec/*
	fi
}
