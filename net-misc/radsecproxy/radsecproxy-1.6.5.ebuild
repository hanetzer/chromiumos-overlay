# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit flag-o-matic

DESCRIPTION="RADIUS over TLS (RadSec) support"
SRC_URI="https://software.uninett.no/radsecproxy/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="dev-libs/openssl"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i -e 's:-pedantic::g' configure || die
}

src_configure() {
	append-cppflags "-D_GNU_SOURCE"
	econf
}
