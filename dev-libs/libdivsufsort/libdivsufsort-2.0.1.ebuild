# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit cmake-utils

DESCRIPTION="library to construct the suffix array and the Burrows-Wheeler transformed string"
HOMEPAGE="http://code.google.com/p/libdivsufsort/"
SRC_URI="http://libdivsufsort.googlecode.com/files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.0.1-libsuffix.patch
}

src_configure() {
	local mycmakeargs="-DBUILD_DIVSUFSORT64=ON"
	tc-export CC
	cmake-utils_src_configure
}
