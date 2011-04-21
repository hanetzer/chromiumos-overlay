#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

inherit toolchain-funcs cros-workon

DESCRIPTION="Utility for looking at top users of system calls"
HOMEPAGE="http://git.chromium.org/gitweb/?s=ktop"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~arm"
IUSE=""

src_compile() {
	tc-export CC
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
}
