# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit eutils

DESCRIPTION="Marvell SD8787 firmware image"
HOMEPAGE="http://www.marvell.com/"
LICENSE="Marvell International Ltd."

SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RESTRICT="binchecks strip test"

DEPEND=""
RDEPEND=""

src_install() {
    local third_party="${CHROMEOS_ROOT}/src/third_party"
    local marvell_dir="${third_party}/marvell"
    dodir /lib/firmware/mrvl || die
    cp -a "${marvell_dir}"/sd8787* "${D}"/lib/firmware/mrvl/ || die
}
