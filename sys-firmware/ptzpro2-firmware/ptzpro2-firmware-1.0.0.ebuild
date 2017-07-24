# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Logitech PTZ Pro 2 firmware"
SRC_URI="https://s3.amazonaws.com/chromiumos/ptzpro2-bin/${P}.tar.gz"

LICENSE="Google-TOS"
SLOT="0"
KEYWORDS="*"

RDEPEND="sys-apps/logitech-updater"
DEPEND=""

S="${WORKDIR}"

src_install() {
	insinto /lib/firmware/logitech/ptzpro2
	doins "ptzpro2_video.bin"
	doins "ptzpro2_eeprom.s19"
	doins "ptzpro2_mcu2.bin"
}
