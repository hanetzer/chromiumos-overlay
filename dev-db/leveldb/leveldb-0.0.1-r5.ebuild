# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=4
CROS_WORKON_COMMIT="117f7a31c15e13937d01cebbf593d3a862a99214"
CROS_WORKON_TREE="a73fe156028f5254fbe8cfbfb76967b7553a3b9d"
CROS_WORKON_PROJECT="chromiumos/third_party/leveldb"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="A fast and lightweight key/value database library by Google."
HOMEPAGE="http://code.google.com/p/leveldb/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CXX OBJCOPY PKG_CONFIG STRIP
	cros-debug-add-NDEBUG
	emake all libmemenv.a
}

src_install() {
	insinto /usr/include/leveldb
	doins include/leveldb/*.h helpers/memenv/memenv.h
	dolib.a libleveldb.a  libmemenv.a
}

