# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# The binaries are from the android pi-arc-dev branch.

# Clang is from
# prebuilts/clang/host/linux-x86/clang-4053586
# Last commit is d9a956564b93ff10c01d9bcda84f99bfe86b4a23

# Gcc is from
# prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9
# Last commit: 65e6e70ed1ba42c3d1e9b608cac7977196f32af4
# prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9
# Last commit: e70c7dff4a433c03ff90f312194f04d8fd1d95c7

# Libraries are from
# https://android-build.googleplex.com/builds/submitted/4657004/cheets_arm-userdebug/latest
# https://android-build.googleplex.com/builds/submitted/4657004/cheets_x86_64-userdebug/latest

# Headers are from
# bionic
# Last commit: b85d0bd2b9d801028c9b0fcb9119df9d15bc27a2
# external/libcxx
# Last commit: 68aaead27cb9afcf496ec4f2f76832e1af675c3c
# frameworks/native/vulkan/include
# Last commit: 1e7c4134c3931c948af6fd89a28aedcb8091d41b

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
