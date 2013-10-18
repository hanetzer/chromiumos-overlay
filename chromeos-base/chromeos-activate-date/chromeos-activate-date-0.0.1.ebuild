# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS activate date mechanism"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

RDEPEND="
	!<chromeos-base/chromeos-bsp-spring-private-0.0.1-r15
	!<chromeos-base/chromeos-bsp-pit-private-0.0.1-r11
	!<chromeos-base/chromeos-bsp-daisy-private-0.0.1-r26
	!<chromeos-base/chromeos-bsp-alex-0.0.1-r11
	!<chromeos-base/chromeos-bsp-lumpy-private-0.0.5-r22
	!<chromeos-base/chromeos-bsp-lumpy-0.0.5-r14
	!<chromeos-base/chromeos-bsp-stumpy-0.0.3-r8
"

S=${WORKDIR}

src_install() {
	dosbin "${FILESDIR}/activate_date"

	insinto "/etc/init"
	doins "${FILESDIR}/activate_date.conf"
}
