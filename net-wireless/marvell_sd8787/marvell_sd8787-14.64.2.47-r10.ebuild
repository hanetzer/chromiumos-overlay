# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=96ad6bc1db0686666b126e2ac41a1c3875e72454
CROS_WORKON_TREE="1dabe093ccfa2d5428c7d8435f1fa8599c024e45"

EAPI="2"
CROS_WORKON_PROJECT="chromiumos/third_party/marvell"

inherit eutils cros-workon

DESCRIPTION="Marvell SD8787 firmware image"
HOMEPAGE="http://www.marvell.com/"
LICENSE="Marvell International Ltd."

SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RESTRICT="binchecks strip test"

DEPEND=""
RDEPEND=""

CROS_WORKON_LOCALNAME="marvell"

src_install() {
    dodir /lib/firmware/mrvl || die
    cp -a "${S}"/sd87* "${D}"/lib/firmware/mrvl/ || die
}
