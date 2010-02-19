# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit eutils

DESCRIPTION="Atheros AR600x firmware"
HOMEPAGE="http://www.atheros.com/"
LICENSE="Atheros"

SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RESTRICT="binchecks strip test"

DEPEND=""
RDEPEND=""

src_install() {
    local third_party="${CHROMEOS_ROOT}/src/third_party"
    local files="${third_party}/atheros-ath6k/files/"
    dodir /lib/firmware || die
    cp -ar "${files}"/firmware/* "${D}"/lib/firmware || die
}
