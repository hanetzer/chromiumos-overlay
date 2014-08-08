# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="0eeb582fb4a1c8651036ae8a63bd127011aeca18"
CROS_WORKON_TREE="9fddc499adeca8d2436d9d503fe23058b46e2866"
CROS_WORKON_PROJECT="chromiumos/third_party/marvell"

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

CROS_WORKON_LOCALNAME="marvell"

src_install() {
	insinto /lib/firmware/mrvl
	if use pcie; then
		doins pcie8*.bin
	else
		doins sd8*.bin
	fi
}
