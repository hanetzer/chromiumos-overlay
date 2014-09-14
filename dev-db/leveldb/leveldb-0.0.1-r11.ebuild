# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=4
CROS_WORKON_COMMIT="f216400e702a51c900f2ce0285fdd6a21d3dd87b"
CROS_WORKON_TREE="d523213c6fb13fa821881eac3b3b28d78403de57"
CROS_WORKON_PROJECT="chromiumos/third_party/leveldb"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="A fast and lightweight key/value database library by Google."
HOMEPAGE="http://code.google.com/p/leveldb/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang snappy"
REQUIRED_USE="asan? ( clang )"

DEPEND="snappy? ( app-arch/snappy )"
RDEPEND="${DEPEND}"

src_configure() {
	clang-setup-env
	cros-workon_src_configure

	# These vars all get picked up by build_detect_platform
	# which the Makefile runs for us automatically.
	tc-export AR CC CXX
	export OPT="-DNDEBUG ${CPPFLAGS}"
}

src_compile() {
	emake SNAPPY=$(usex snappy) all libmemenv.a
}

src_install() {
	insinto /usr/include/leveldb
	doins include/leveldb/*.h helpers/memenv/memenv.h
	dolib.a libleveldb.a libmemenv.a
}

