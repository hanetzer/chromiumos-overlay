# Copyright 2010 Google Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"

inherit cros-workon toolchain-funcs

DESCRIPTION="Utilities for modifying coreboot firmware images"
HOMEPAGE="http://coreboot.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~x86"

CROS_WORKON_LOCALNAME="coreboot"

RDEPEND=""

src_compile() {
	local make_flags="CC=\"$(tc-getCC)\" strip=''"
	cd util/ifdtool; emake ${make_flags} || die
	cd ../cbfstool; emake ${make_flags} || die
}

src_install() {
	dobin util/cbfstool/cbfstool || die
	dobin util/ifdtool/ifdtool || die
}
