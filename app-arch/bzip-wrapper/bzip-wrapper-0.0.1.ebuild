# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Wrapper for bzip2"
HOMEPAGE="http://chromium.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 arm"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	exeinto /usr/bin/
	doexe "${FILESDIR}/bzip-wrapper"
	dosym "bzip-wrapper" "/usr/bin/bunzip-wrapper"
}
