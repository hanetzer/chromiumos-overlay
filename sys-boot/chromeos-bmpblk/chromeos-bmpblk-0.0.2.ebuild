# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-binary

DESCRIPTION="Chrome OS Firmware Bitmap Block"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

BMPBLK_NAME="bmpblk-${PV}.bin"
MIRROR_SITE="http://commondatastorage.googleapis.com/chromeos-localmirror"
CROS_BINARY_URI="$MIRROR_SITE/distfiles/$PN/$BMPBLK_NAME"
CROS_BINARY_SUM="52017d404ac67be56cfd1d46b129443c6f1b7ba5"

src_install() {
	insinto /firmware
	newins "$CROS_BINARY_STORE_DIR/$BMPBLK_NAME" bmpblk.bin
}
