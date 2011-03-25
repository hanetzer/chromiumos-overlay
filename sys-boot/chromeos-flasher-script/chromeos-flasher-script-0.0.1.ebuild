# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit eutils

DESCRIPTION="U-Boot Flasher scripts"
LICENSE=""
SLOT="0"
KEYWORDS="arm"
IUSE="bootflash-nand bootflash-spi"

RDEPEND=""
DEPEND=""

if use bootflash-nand; then
	FLASHER_SCRIPT="nand.script"
elif use bootflash-spi; then
	FLASHER_SCRIPT="spi.script"
fi

src_configure() {
	local script=${FILESDIR}/${FLASHER_SCRIPT}

	if [ -z "${FLASHER_SCRIPT}" ]; then
		die "No flasher script selected."
	fi

	einfo "Using flasher script: ${script}"
}

src_install() {
	dodir /u-boot
	insinto /u-boot

	doins "${FILESDIR}/${FLASHER_SCRIPT}"
	dosym "${FLASHER_SCRIPT}" /u-boot/flasher.script
}
