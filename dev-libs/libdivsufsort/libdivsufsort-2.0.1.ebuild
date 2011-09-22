# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit cmake-utils

DESCRIPTION="The libdivsufsort project provides a fast, lightweight, and robust
C API library to construct the suffix array and the Burrows-Wheeler transformed
string for any input string of a constant-size alphabet."
HOMEPAGE="http://code.google.com/p/libdivsufsort/"
SRC_URI="http://libdivsufsort.googlecode.com/files/libdivsufsort-2.0.1.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.0.1-libsuffix.patch
}

src_configure() {
	local mycmakeargs="-DBUILD_DIVSUFSORT64=ON"
	tc-export CC
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
