# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Atheros 10k firmware"
HOMEPAGE="http://wireless.kernel.org/en/users/Drivers/ath10k/firmware"

GIT_SHA1="da0f85d924226ee30c46e037120621c9e192b39e"
MY_P=${PN}-da0f85d
SRC_URI="http://github.com/kvalo/ath10k-firmware/archive/${GIT_SHA1}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LICENCE.atheros_firmware"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}/${PN}-${GIT_SHA1}

src_install() {
	insinto /lib/firmware/ath10k/QCA988X/hw2.0
	doins ath10k/QCA988X/hw2.0/board.bin
	newins 10.2.4/firmware-4.bin_10.2.4.45 firmware-4.bin
	newins 10.2.4/notice.txt_10.2.4.45 notice.txt
}
