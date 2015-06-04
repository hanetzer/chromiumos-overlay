# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Atheros 10k firmware"
HOMEPAGE="http://wireless.kernel.org/en/users/Drivers/ath10k/firmware"

GIT_SHA1="b46f3e01a6c1f9150fb4612ef53611d714565842"
MY_P=${PN}-b46f3e
SRC_URI="http://github.com/kvalo/ath10k-firmware/archive/${GIT_SHA1}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LICENSE.qca_firmware"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}/${PN}-${GIT_SHA1}

src_install() {
	insinto /lib/firmware/ath10k/QCA988X/hw2.0
	doins ath10k/QCA988X/hw2.0/board.bin
	newins 10.2.4/untested/firmware-5.bin_10.2.4.70-2 firmware-5.bin
	newins 10.2.4/untested/notice.txt_10.2.4.70-2 notice.txt
}
