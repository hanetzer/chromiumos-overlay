# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="48567ce496f2f32e664ef7ae8c34601e9e649b54"
CROS_WORKON_TREE="94053fff9e9c6d7b28d8f9f9626c4159bd508f2c"
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
