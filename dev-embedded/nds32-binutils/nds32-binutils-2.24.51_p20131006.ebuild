# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

BINUTILS_VER=${PV%_p*}

inherit toolchain-binutils

DESCRIPTION="Tools necessary to build programs for Andes cores"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/nds32-binutils-6a663c8.tar.gz"

KEYWORDS="~amd64 ~x86"

# needed to fix bug #381633
RDEPEND=">=sys-devel/binutils-config-3-r2"

pkg_setup() {
	is_cross || die "Only cross-compile builds are supported"
}
