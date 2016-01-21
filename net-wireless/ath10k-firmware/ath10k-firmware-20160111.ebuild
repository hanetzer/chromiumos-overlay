# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Atheros 10k firmware"
HOMEPAGE="http://wireless.kernel.org/en/users/Drivers/ath10k/firmware"

GIT_SHA1="e61e178e32a9b7295db3a359a00c8ccb5b49e408"
MY_P=${PN}-e61e178
SRC_URI="http://github.com/kvalo/ath10k-firmware/archive/${GIT_SHA1}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LICENSE.qca_firmware"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}/${PN}-${GIT_SHA1}

src_prepare() {
# Remove Makefile. It causes the ebuild to run make on the Makefile
# resulting in a failure. All we need is firmware binary and board bin.
	rm Makefile
}

src_install() {
	insinto /lib/firmware/ath10k/QCA988X/hw2.0
	doins QCA988X/board.bin
	newins QCA988X/10.2.4/firmware-5.bin_10.2.4.70.17-2 firmware-5.bin
	newins QCA988X/10.2.4/notice.txt_10.2.4.70.17-2 notice.txt
}
