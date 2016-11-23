# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# The binaries are from the android nyc-arc branch.

# Clang is from
# prebuilts/clang/host/linux-x86/clang-2690385
# Last commit is 45562a53b2a5eb7c6e8f400413d19a12c660d7b1

# Gcc is from
# prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9
# Last commit: 0390252b6bcc6217966ade31d07f8b12f6f78f89
# prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9
# Last commit: 54c4ed4b1a910bcc8e37196acb7fa85e872de9e4

# Libraries are from
# https://android-build.googleplex.com/builds/submitted/3501667/cheets_arm-userdebug/latest
# https://android-build.googleplex.com/builds/submitted/3501667/cheets_x86-userdebug/latest

# Headers are from
# bionic
# Last commit: c3474c7adbfd5f3f320dc569bd85bbfda1dab9ba
# external/libcxx
# Last commit: d8170174bf66c98fca967b7133783c0c95292993

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

clobber() {
	touch "$1"
	tee "$1" > /dev/null
}

create_pkgconfig_wrapper() {
	local IMAGE_DIR="${D}/${INSTALL_DIR}"
	local TARGET="${IMAGE_DIR}/pkg-config-arc"
	clobber "${TARGET}" <<EOF
#!/bin/bash

PKG_CONFIG_LIBDIR="${INSTALL_DIR}/pkgconfig"
export PKG_CONFIG_LIBDIR

export PKG_CONFIG_SYSROOT_DIR="${INSTALL_DIR}/\$1"

# Portage will get confused and try to "help" us by exporting this.
# Undo that logic.
unset PKG_CONFIG_PATH

exec pkg-config "\${@:2}"
EOF
	chmod a+rx "${TARGET}"
}

src_install() {
	dodir ${INSTALL_DIR}
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
	cp -pPR "${FILESDIR}/pkgconfig" "${D}/${INSTALL_DIR}/" || die
	create_pkgconfig_wrapper
}
