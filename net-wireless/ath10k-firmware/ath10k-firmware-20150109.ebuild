# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Atheros 10k firmware"
HOMEPAGE="http://wireless.kernel.org/en/users/Drivers/ath10k/firmware"

GIT_SHA1="8db9630c49ebbb50892781856bd4539739eedf4d"
MY_P=${PN}-8db9630
SRC_URI="http://github.com/kvalo/ath10k-firmware/archive/${GIT_SHA1}.tar.gz -> ${MY_P}.tar.gz"

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
	newins 10.2.4/firmware-4.bin_10.2.4.13-2 firmware-4.bin
}
