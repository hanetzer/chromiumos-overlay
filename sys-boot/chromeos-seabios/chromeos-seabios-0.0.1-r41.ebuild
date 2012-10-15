# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="589e763e493ff2544d2f98cdfaceed6865e066b8"
CROS_WORKON_TREE="aac8fef67a3b7b56c9b6cb32af538d32e9e70b15"

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
	doins bootorder || die
	doins boot-menu-wait || die
}
