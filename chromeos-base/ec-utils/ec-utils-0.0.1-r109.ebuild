# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="f411bbbe19b91ee8fa22fa3c04468127d85e46e1"
CROS_WORKON_TREE="cf9782e7f127d2fcaa9da03cb50f99f15983e0d7"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="../platform/ec"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS EC Utility"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

# The BOARD is a special parameter. It should be the ChromeOS board name if you
# are building EC firmware itself. However, for utility, we can always build
# the reference configuration "bds" because the protocol should be always
# compliant to reference one.
BOARD="bds"

src_compile() {
	tc-export AR CC RANLIB
	# In platform/ec Makefile, it uses "CC" to specify target chipset and
	# "HOSTCC" to compile the utility program because it assumes developers
	# want to run the utility from same host (build machine).
	# In this ebuild file, we only build utility and we want the utility to
	# be executed on target devices (i.e., arm/x86/amd64), not the build
	# host (BUILDCC, amd64). So we need to override HOSTCC by target "CC".
	export HOSTCC="$CC"
	emake utils
}

src_install() {
	dosbin "build/$BOARD/util/ectool"
}
