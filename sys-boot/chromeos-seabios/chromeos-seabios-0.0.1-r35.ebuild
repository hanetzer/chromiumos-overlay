# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="5dc13f9d6ac3f7cb7cb1b8e3422309ed10827dc2"
CROS_WORKON_TREE="0ef2c2a72254febfc200c6fe9c0c3a514a1db57e"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/seabios"

inherit toolchain-funcs

DESCRIPTION="Open Source implementation of X86 BIOS"
HOMEPAGE="http://www.coreboot.org/SeaBIOS"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=""
DEPEND=""

CROS_WORKON_LOCALNAME="seabios"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

src_compile() {
	export LD="$(tc-getLD).bfd"
	export CC="$(tc-getCC) -fuse-ld=bfd"
	emake defconfig || die "${P}: configuration failed"
	emake || die "${P}: compilation failed"
}

src_install() {
	dodir /firmware
	insinto /firmware
	doins out/bios.bin.elf || die
}
