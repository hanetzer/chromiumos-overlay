# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="b63dc7deb90befeb43f82641d8b8be9ad51c7e25"
inherit eutils cros-workon

DESCRIPTION="Marvell SD8787 firmware image"
HOMEPAGE="http://www.marvell.com/"
LICENSE="Marvell International Ltd."

SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RESTRICT="binchecks strip test"

DEPEND=""
RDEPEND=""

CROS_WORKON_LOCALNAME="marvell"
CROS_WORKON_PROJECT="marvell"

src_install() {
    dodir /lib/firmware/mrvl || die
    cp -a "${S}"/sd8787* "${D}"/lib/firmware/mrvl/ || die
}
