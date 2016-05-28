# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Ebuild for Android Libs (libc, libcxx, etc)."
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3 GPL-3"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S=${WORKDIR}
INSTALL_DIR="/opt/android"


# These prebuilts are already properly stripped.
RESTRICT="strip"
QA_PREBUILT="*"

src_install() {
	dodir ${INSTALL_DIR}
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
}
