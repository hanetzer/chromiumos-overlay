# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bsdiff/bsdiff-4.3-r2.ebuild,v 1.1 2010/12/13 00:35:03 flameeyes Exp $

EAPI=4

inherit eutils toolchain-funcs flag-o-matic

IUSE=""

DESCRIPTION="bsdiff: Binary Differencer using a suffix alg"
HOMEPAGE="http://www.daemonology.net/bsdiff/"
SRC_URI="http://www.daemonology.net/bsdiff/${P}.tar.gz"

SLOT="0"
LICENSE="BSD-2"
KEYWORDS="*"

RDEPEND="app-arch/bzip2
	dev-libs/libdivsufsort"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PV}_bspatch-extent-files.patch
	epatch "${FILESDIR}"/${PV}_bsdiff-divsufsort.patch
	epatch "${FILESDIR}"/${PV}_makefile.patch
	epatch "${FILESDIR}"/${PV}_sanity_check.patch
}

src_configure() {
	append-lfs-flags
        tc-export CC
}
