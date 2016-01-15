# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Ebuild for Android llvm. This copies the prebuilts"
HOMEPAGE="http://llvm.org/"
GIT_SHAI="4612848f6fe464e94f5343b53ab1df30ba619288"
SRC_URI="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86//+archive/${GIT_SHAI}.tar.gz -> ${P}.tar.gz"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S=${WORKDIR}

INSTALL_DIR="/opt/android"

src_install() {
	dodir "${INSTALL_DIR}"
	cp -pPR [0-9].[0-9]* "${D}/${INSTALL_DIR}/" || die
}
