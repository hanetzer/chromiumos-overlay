# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bsdiff/bsdiff-4.3-r1.ebuild,v 1.12 2010/01/15 21:21:10 fauli Exp $

inherit eutils toolchain-funcs flag-o-matic

EAPI=2
IUSE=""

DESCRIPTION="bsdiff: Binary Differencer using a suffix alg"
HOMEPAGE="http://www.daemonology.net/bsdiff/"
SRC_URI="http://www.daemonology.net/bsdiff/${P}.tar.gz"

SLOT="0"
LICENSE="BSD-2"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"

DEPEND="app-arch/bzip2"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch ${FILESDIR}/4.3_bspatch-support-input-output-positioning.patch
}

src_compile() {
	append-lfs-flags
	$(tc-getCC) ${CFLAGS} -D_FILE_OFFSET_BITS=64 ${LDFLAGS} -o bsdiff bsdiff.c -lbz2 || die "failed compiling bsdiff"
	$(tc-getCC) ${CFLAGS} -D_FILE_OFFSET_BITS=64 ${LDFLAGS} -o bspatch bspatch.c -lbz2 || die "failed compiling bspatch"
}

src_install() {
	dobin bs{diff,patch}
	doman bs{diff,patch}.1
}
