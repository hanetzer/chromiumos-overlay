# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Ebuild that installs Realtek 2800 USB firmware."

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm amd64"

RT2800_USB_FW_NAME="rt2870.bin"

S=${WORKDIR}

src_install() {
	insinto /lib/firmware
	doins "${FILESDIR}/${RT2800_USB_FW_NAME}"
}
