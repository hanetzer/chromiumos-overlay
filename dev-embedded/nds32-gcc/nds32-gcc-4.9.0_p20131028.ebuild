# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

BRANCH_UPDATE=""

inherit toolchain

DESCRIPTION="The GNU Compiler Collection for Andes cores"
LICENSE="GPL-3 LGPL-3 || ( GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.2"
KEYWORDS="amd64 x86"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/nds32-gcc-cf268d08.tar.gz"

RDEPEND=""
DEPEND="${RDEPEND}
	${CATEGORY}/nds32-binutils"

ETYPE="gcc-compiler"
GCC_A_FAKEIT="nds32-gcc-cf268d08.tar.gz"

pkg_pretend() {
	is_crosscompile || die "Only cross-compile builds are supported"
}
