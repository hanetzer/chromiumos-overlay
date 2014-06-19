# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS Firmware Bitmap Block"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="amd64 arm x86"

MIRROR_SITE="http://commondatastorage.googleapis.com/chromeos-localmirror"
[[ "${PV}" != "0" ]] && SRC_URI="${MIRROR_SITE}/distfiles/${P}.tbz2"
S=${WORKDIR}

src_install() {
	insinto /firmware
	doins bmpblk.bin
}
