# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# The binaries are from the android pi-arc-dev branch.

# Clang is from
# prebuilts/clang/host/linux-x86/clang-4639204
# Last commit: a4672a747d65420efe8c8dcb796621e38412d1d4

# Gcc is from
# prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9
# Last commit: 75a43d595cbbd637294e0c54d98051fe03e06b83
# prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9
# Last commit: a137b149dc4eecca65e037457b4809da38ea8f77

# Libraries are from
# https://android-build.googleplex.com/builds/submitted/4684564/cheets_arm-userdebug/latest
# https://android-build.googleplex.com/builds/submitted/4684564/cheets_x86_64-userdebug/latest

# Headers are from
# bionic
# Last commit: 5a6b9565c0e3f08f9675abad5c1c34752fb47b17
# external/libcxx
# Last commit: 68aaead27cb9afcf496ec4f2f76832e1af675c3c
# frameworks/native/vulkan/include
# Last commit: fd78e946c160ec3b4078703db8f67d9092c90323

EAPI=5

DESCRIPTION="Ebuild for Android toolchain (compilers, linker, libraries, headers)."
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3 GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 FDL-1.2 UoI-NCSA"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S="${WORKDIR}"
INSTALL_DIR="/opt/android-p"


# These prebuilts are already properly stripped.
RESTRICT="strip"
QA_PREBUILT="*"

src_install() {
	dodir "${INSTALL_DIR}"
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
}
