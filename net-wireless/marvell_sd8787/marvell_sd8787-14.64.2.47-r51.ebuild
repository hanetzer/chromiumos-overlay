# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="16aaabeb9260596973d879dc17c6a6176c84497f"
CROS_WORKON_TREE="e96d4af9f0cc0956ad4ef2fa967ed204302a91be"
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
