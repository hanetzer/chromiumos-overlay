# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Ebuild for Android GCC. This copies the prebuilts"
HOMEPAGE="https://gcc.gnu.org/"
GIT_SHAI="0390252b6bcc6217966ade31d07f8b12f6f78f89"
SRC_URI="https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/${GIT_SHAI}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3 LGPL-3 GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 FDL-1.2"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S=${WORKDIR}

INSTALL_DIR="/opt/android"

src_install() {
	dodir "${INSTALL_DIR}"
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
}
