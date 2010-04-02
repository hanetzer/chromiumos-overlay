# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Command-line flags module for Unix shell scripts"
HOMEPAGE="http://code.google.com/p/shflags/"
SRC_URI="http://shflags.googlecode.com/files/${P}.tgz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	dolib src/shflags
}
