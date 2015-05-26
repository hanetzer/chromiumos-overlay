# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Atheros 10k firmware"
HOMEPAGE="http://wireless.kernel.org/en/users/Drivers/ath10k/firmware"

GIT_SHA1="5317c33b65edff9f4bd6b682ce6ba4afed1b2fe4"
MY_P=${PN}-5317c33
SRC_URI="http://github.com/kvalo/ath10k-firmware/archive/${GIT_SHA1}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LICENSE.qca_firmware"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}/${PN}-${GIT_SHA1}

src_install() {
	insinto /lib/firmware/ath10k/QCA988X/hw2.0
	doins ath10k/QCA988X/hw2.0/board.bin
	newins 10.2.4/untested/firmware-5.bin_10.2.4.68-2 firmware-5.bin
	newins 10.2.4/untested/notice.txt_10.2.4.68-2 notice.txt
}
