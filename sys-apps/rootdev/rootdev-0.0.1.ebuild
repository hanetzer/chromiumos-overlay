# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit toolchain-funcs

DESCRIPTION="display rootfs device"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

# Where is source directory?
SRCPATH=src/third_party/rootdev/files

src_unpack() {
	cp -a "${CHROMEOS_ROOT}/${SRCPATH}" "${S}" || die
}

src_compile() {
	tc-getCC
	emake || die "${SRCPATH} compile failed."
}

src_install() {
	dodir /usr/bin
	exeinto /usr/bin
	doexe ${S}/rootdev
}
