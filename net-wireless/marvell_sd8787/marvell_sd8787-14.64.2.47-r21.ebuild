# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ec5274d27377f8ae2e31af0e452131a91c6a5b67"
CROS_WORKON_TREE="c814953048e4ce18ceec50efeaca484dfd983101"
CROS_WORKON_PROJECT="chromiumos/third_party/marvell"

inherit eutils cros-workon

DESCRIPTION="Marvell SD8787 firmware image"
HOMEPAGE="http://www.marvell.com/"
LICENSE="Marvell International Ltd."

SLOT="0"
KEYWORDS="amd64 arm x86"
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
