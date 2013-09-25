# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="4"

DESCRIPTION="NVRAM image for the brcmfmac driver"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm"
IUSE="awnh610 awnh930"
REQUIRED_USE="|| ( ${IUSE} )"

S=${WORKDIR}

src_install() {
	insinto /lib/firmware/brcm
	if use awnh610 ; then
		newins "${FILESDIR}"/bcm4329-fullmac-4.txt-awnh610 bcm4329-fullmac-4.txt
	elif use awnh930 ; then
		newins "${FILESDIR}"/bcm4329-fullmac-4.txt-awnh930 bcm4329-fullmac-4.txt
	fi
}
