# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Extensible Virtual Display Interface Library"
HOMEPAGE="https://github.com/DisplayLink/evdi"
SRC_URI="https://github.com/DisplayLink/evdi/archive/e3544b223fb6f3a7f766b62cf358ae80f2d40a85.tar.gz -> ${P}.tar.gz"

# evdi has mixed license: GPLv2 for the module, LGPL-2.1 for the library.
# However, this ebuild is for the library only.
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

# We need drm only for its structs and defines, not for functions.
DEPEND="x11-libs/libdrm"

S=${WORKDIR}

src_unpack() {
	default
	cd "${WORKDIR}"/${PN}-*
	S=${PWD}
}

src_compile() {
	tc-export CC
	append-cppflags -DCHROMEOS -I../module
	emake -C library
}

src_install() {
	dolib.so library/libevdi.so

	insinto /usr/include
	doins library/evdi_lib.h
}
