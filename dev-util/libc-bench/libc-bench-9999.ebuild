# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/libc-bench"

inherit cros-workon toolchain-funcs

DESCRIPTION="Time and memory-efficiency tests of various C/POSIX standard library functions"
HOMEPAGE="http://www.etalabs.net/libc-bench.html"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

RDEPEND=""
DEPEND=""

src_compile() {
	tc-export CC CXX PKG_CONFIG
	emake || die "end compile failed."
}

src_install() {
	INSTALL_DIR=/usr/local/libc-bench/
	dodir $INSTALL_DIR
	exeinto $INSTALL_DIR
	doexe libc-bench
}
