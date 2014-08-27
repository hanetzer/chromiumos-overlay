# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Atheros 10k firmware"
HOMEPAGE="http://wireless.kernel.org/en/users/Drivers/ath10k/firmware"

MY_P=${PN}-f450fd3
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${MY_P}.tar.gz"

LICENSE="LICENCE.atheros_firmware"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}/${MY_P}

src_install() {
	insinto /lib/firmware/ath10k/QCA988X/hw2.0
	doins ath10k/QCA988X/hw2.0/board.bin
	doins ath10k/QCA988X/hw2.0/firmware-2.bin
	newins 10.2/firmware-3.bin_10.2-00082-4-2 firmware-3.bin
}
