# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit eutils

DESCRIPTION="An image comparison utility."
HOMEPAGE="http://pdiff.sourceforge.net/"
SRC_URI="mirror://sourceforge/pdiff/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86"
IUSE=""

DEPEND="media-libs/freeimage"

DOCS="gpl.txt README.txt"

src_prepare() {
        epatch "${FILESDIR}"/CMakeFiles-search-in-SYSROOT.patch  
        epatch "${FILESDIR}"/Metric.cpp-printf-needs-stdio.patch
}

src_configure() {        
        tc-export CC CXX AR RANLIB LD NM
        cmake . || die cmake failed
}

src_install() {
        dobin perceptualdiff
}