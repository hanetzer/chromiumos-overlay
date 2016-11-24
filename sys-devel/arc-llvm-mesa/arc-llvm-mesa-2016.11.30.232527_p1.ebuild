# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Ebuild for Android LLVM runtime."
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S=${WORKDIR}
INSTALL_DIR="/opt/android/arc-llvm-mesa"

# These prebuilts are already properly stripped.
RESTRICT="strip"
QA_PREBUILT="*"

src_install() {
	dodir ${INSTALL_DIR}
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
}
