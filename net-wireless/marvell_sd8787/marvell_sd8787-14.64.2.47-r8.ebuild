# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="9fa10832efefc59af8d1c2d7fd1a07f218f3a606"
CROS_WORKON_TREE="3330d9379228e7ddb4f47d625e542a69102627b5"

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
