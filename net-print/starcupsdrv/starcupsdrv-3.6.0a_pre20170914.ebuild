# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils

DESCRIPTION="CUPS filter and PPD files for Star Micronics printers"
HOMEPAGE="http://www.starmicronics.com"
SRC_URI="http://www.starmicronics.com/support/DriverFolder/drvr/starcupsdrv-${PV%_*}_linux_${PV#*_pre}.tar.gz -> starcupsdrv-${PV%_*}_linux_${PV#*_pre}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-3.6.0a-build-fix.patch"
)

src_unpack() {
	default
	unpack ./${PN}-${PV%_*}_linux/SourceCode/starcupsdrv-src-${PV%_*}.tar.gz
	mv starcupsdrv starcupsdrv-${PV} || die
}

src_prepare() {
	epatch "${PATCHES[@]}"
	epatch_user
}

src_install() {
	exeinto "$(${SYSROOT}/usr/bin/cups-config --serverbin)/filter"
	doexe install/rastertostar
	doexe install/rastertostarlm
}
