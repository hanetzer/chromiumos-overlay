# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="db05d126a42a1540a503a2e5b49c3746c03df77d"
CROS_WORKON_TREE="4db0013801be280ced37d4d0229bddb0b41de11c"
CROS_WORKON_PROJECT="chromiumos/third_party/marvell"
CROS_WORKON_LOCALNAME="marvell"

inherit eutils cros-workon

DESCRIPTION="Marvell SD8787 firmware image"
HOMEPAGE="http://www.marvell.com/"
LICENSE="Marvell-sd8787"

SLOT="0"
KEYWORDS="*"
IUSE="pcie"

RESTRICT="binchecks strip test"

DEPEND=""
RDEPEND=""

src_install() {
	insinto /lib/firmware/mrvl
	if use pcie; then
		doins pcie8*.bin
	else
		doins sd8*.bin
	fi
}
