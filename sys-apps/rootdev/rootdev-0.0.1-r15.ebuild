# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="15141a9e18d299ca1f13f5dd414b78499b59407b"
CROS_WORKON_TREE="7944ea7cf7fc0cb49ffe1633c9ad4331fd76989d"
CROS_WORKON_PROJECT="chromiumos/third_party/rootdev"

inherit toolchain-funcs cros-workon

DESCRIPTION="Chrome OS root block device tool/library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-getCC
	emake || die
}

src_install() {
	dodir /usr/bin
	exeinto /usr/bin
	doexe ${S}/rootdev

	dodir /usr/lib
	dolib.so librootdev.so*

	dodir /usr/include/rootdev
	insinto /usr/include/rootdev
	doins rootdev.h
}
