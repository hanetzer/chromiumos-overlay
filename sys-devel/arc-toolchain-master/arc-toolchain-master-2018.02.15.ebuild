# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# The binaries are from the android master branch.

# Clang is from
# prebuilts/clang/host/linux-x86/clang-4053586
# Last commit is d9a956564b93ff10c01d9bcda84f99bfe86b4a23

# Gcc is from
# prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9
# Last commit: efea8fa51447a95895ad64c38bfede04ce735866
# prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9
# Last commit: 5f6246e27efc3737c1502c275f3523edf97d2044

# Libraries are from
# https://android-build.googleplex.com/builds/submitted/4605468/cheets_arm-userdebug/latest
# https://android-build.googleplex.com/builds/submitted/4605468/cheets_x86_64-userdebug/latest

# Headers are from
# bionic
# Last commit: 3b2caecfca46c92793d7856d56f6dabc3cc61d1a
# external/libcxx
# Last commit: 09aa642224808b83271550fb1eda6899201353db
# frameworks/native/vulkan/include
# Last commit: d0e91e778e019fc79ee7011ea6713b2b2f2512f4

EAPI=5

DESCRIPTION="Ebuild for Android toolchain (compilers, linker, libraries, headers)."
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3 GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 FDL-1.2 UoI-NCSA"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S="${WORKDIR}"
INSTALL_DIR="/opt/android-master"


# These prebuilts are already properly stripped.
RESTRICT="strip"
QA_PREBUILT="*"

src_install() {
	dodir "${INSTALL_DIR}"
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
}
