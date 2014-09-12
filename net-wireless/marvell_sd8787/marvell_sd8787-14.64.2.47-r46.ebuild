# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="17a2455ce0d1fe3adab087e96e2b9d9e39c74a14"
CROS_WORKON_TREE="4ed6d0fe4fa0efab9f3aab804f81d6fec0f4e374"
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
