# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

DESCRIPTION="Google's C++ testing framework."
HOMEPAGE="http://code.google.com/p/googletest/"
SRC_URI="http://googletest.googlecode.com/files/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
