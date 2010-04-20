# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"

inherit autotools base eutils linux-info cmake-utils

DESCRIPTION="TPM Emulator with small google-local changes"
LICENSE="GPL-2"
HOMEPAGE="//https://developer.berlios.de/projects/tpm-emulator"
SLOT="0"
IUSE="doc"
KEYWORDS="x86 amd64 arm"

DEPEND="app-crypt/trousers
        dev-libs/gmp"

src_unpack() {
	if [ -n "$CHROMEOS_ROOT" ] ; then
    		local dir="${CHROMEOS_ROOT}/src/third_party/tpm-emulator"
		elog "Using dir: $dir"
		mkdir -p "${S}"
		cp -a "${dir}"/* "${S}" || die
		# removes possible garbage
		(cd "${S}"; rm -rf build)
	else
		die CHROMEOS_ROOT is not set
	fi
}

src_configure() {
	tc-export CC CXX LD AR RANLIB NM
        CHROMEOS=1 cmake-utils_src_configure
        
}

src_compile() {
        cmake-utils_src_compile
}

src_install() {
	# TODO(semenzato): need these for emerge on host, to run tpm_lite tests.
	# insinto /usr/lib
	# doins ${CMAKE_BUILD_DIR}/tpm/libtpm.a
        # doins ${CMAKE_BUILD_DIR}/crypto/libcrypto.a
	# doins ${CMAKE_BUILD_DIR}/tpmd/unix/libtpmemu.a
	# insinto /usr/include
	# doins ${S}/tpmd/unix/tpmemu.h
	exeinto /usr/sbin
	doexe ${CMAKE_BUILD_DIR}/tpmd/unix/tpmd
}
