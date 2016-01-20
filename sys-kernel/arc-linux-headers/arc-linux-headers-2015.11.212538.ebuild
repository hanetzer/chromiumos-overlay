# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Linux Kernel headers for Android"
HOMEPAGE="https://www.kernel.org/"

GIT_SHAI="2b1e258fec89a5abd20f6d7ee8a102cd9b2c27bc"
SRC_URI="https://android.googlesource.com/platform/bionic/+archive/${GIT_SHAI}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="*"

SLOT="0"

S=${WORKDIR}
INSTALL_DIR="/opt/android/usr/include"

src_install() {
	dodir "${INSTALL_DIR}"
	cp -pPR libc/kernel/uapi/* "${D}/${INSTALL_DIR}/" || die
}
