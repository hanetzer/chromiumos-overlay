# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-constants

DESCRIPTION="Client portion of autotest installed at image creation time"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

DEPEND="
	chromeos-base/autotest
"

S=${WORKDIR}

src_install() {
	dodir /usr/local/autotest
	tar xvf "${SYSROOT}/${AUTOTEST_BASE}/packages/client-autotest.tar.bz2" \
		-C "${D}"/usr/local/autotest || die
}
