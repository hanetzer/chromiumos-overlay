# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="76793dd4b09191a78a78180012718e72d792717f"
CROS_WORKON_TREE="220992de8718504445ad9e1c567f2ccf26de3a11"
CROS_WORKON_PROJECT="chromiumos/third_party/libc-bench"

inherit cros-workon toolchain-funcs

DESCRIPTION="Time and memory-efficiency tests of various C/POSIX standard library functions"
HOMEPAGE="http://www.etalabs.net/libc-bench.html http://git.musl-libc.org/cgit/libc-bench/"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
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
