# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="50f710e8856e9627967371a907cd4dff871cbd03"
CROS_WORKON_TREE="be13a4a5ea8f82899bca64f6d7e944bc88689f68"
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
