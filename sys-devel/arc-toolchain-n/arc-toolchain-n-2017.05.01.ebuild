# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# The binaries are from the android nyc-arc branch.

# Clang is from
# prebuilts/clang/host/linux-x86/clang-2690385
# Last commit is 42541fcf245ae2f4abead994b65603a02ffddea0

# Gcc is from
# prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9
# Last commit: 0390252b6bcc6217966ade31d07f8b12f6f78f89
# prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9
# Last commit: 54c4ed4b1a910bcc8e37196acb7fa85e872de9e4

# Libraries are from
# https://android-build.googleplex.com/builds/submitted/3960532/cheets_arm-userdebug/latest
# https://android-build.googleplex.com/builds/submitted/3960532/cheets_x86-userdebug/latest
# https://android-build.googleplex.com/builds/submitted/3960532/cheets_x86_64-userdebug/latest

# Headers are from
# bionic
# Last commit: 6d71e6543f7c7a45d9ce597986a019fe1b877bca
# external/libcxx
# Last commit: 79a397804f08fd80a51e7b6c0b7d6d7880a530ea
# external/llvm
# Last commit: 9e582cde9f72e7fab98a3eb3e39a59081601be2c

EAPI=5

DESCRIPTION="Ebuild for Android toolchain (compilers, linker, libraries, headers)."
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3 GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 FDL-1.2 UoI-NCSA"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S=${WORKDIR}
INSTALL_DIR="/opt/android-n"


# These prebuilts are already properly stripped.
RESTRICT="strip"
QA_PREBUILT="*"

src_install() {
	dodir ${INSTALL_DIR}
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
}
