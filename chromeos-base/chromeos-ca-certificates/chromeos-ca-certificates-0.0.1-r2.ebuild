# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS restricted set of certificates"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

src_install() {
	CA_CERT_DIR=/usr/share/chromeos-ca-certificates
	insinto "${CA_CERT_DIR}"
	doins "${FILESDIR}"/*.pem
	c_rehash "${D}/${CA_CERT_DIR}"
}
