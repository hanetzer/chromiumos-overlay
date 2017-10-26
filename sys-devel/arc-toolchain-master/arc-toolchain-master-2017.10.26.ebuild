# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# The binaries are from the android master branch.

# Clang is from
# prebuilts/clang/host/linux-x86/clang-4053586
# Last commit is 5f131c01b2029e4f1d2a4e9aa9f55aaa49047601

# Gcc is from
# prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9
# Last commit: ff98796d7a8b1b0331201a5de28f304bdb8f8041
# prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9
# Last commit: 00d54f85f120023a1aec62d0e2b7ba313f877539

# Libraries are from
# https://android-build.googleplex.com/builds/submitted/4207971/cheets_arm-userdebug/latest
# https://android-build.googleplex.com/builds/submitted/4207971/cheets_x86_64-userdebug/latest

# Headers are from
# bionic
# Last commit: 73a57f5814168dfffe18b44ea5e5117c4d8c3b54
# external/libcxx
# Last commit: 5e523c742961f2f34436ef97406b6c9272482bf4
# external/llvm
# Last commit: 55358ef5fd2616530d62f411578fead8aff45eff
# frameworks/native/vulkan/include
# Last commit: fabd2f5c8f31b352a87c6d22228a6c6b5614522a

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
