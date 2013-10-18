# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Ebuild that installs Realtek 2800 USB firmware."

HOMEPAGE="http://git.kernel.org/?p=linux/kernel/git/firmware/linux-firmware.git"
LICENSE="ralink-firmware"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

RT2800_USB_FW_NAME="rt2870.bin"

S=${WORKDIR}

src_install() {
	insinto /lib/firmware
	doins "${FILESDIR}/${RT2800_USB_FW_NAME}"
}
