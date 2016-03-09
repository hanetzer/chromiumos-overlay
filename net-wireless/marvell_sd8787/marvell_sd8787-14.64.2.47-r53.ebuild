# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f3a48ad1a911ce0bc8110279e314d718e2fa54a8"
CROS_WORKON_TREE="19d89c2b1dd2f13867a34078f7bf0e163bc19230"
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
