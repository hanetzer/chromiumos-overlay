# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="52a5bdaa8930c14ee42518354de3e5ec09911c6b"
CROS_WORKON_TREE="a214d22b4c8a8f3cf46dd4a8b80451231eedb9dc"
CROS_WORKON_PROJECT="chromiumos/third_party/atheros"
CROS_WORKON_LOCALNAME="atheros"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon

DESCRIPTION="Atheros AR3012 firmware"
HOMEPAGE="http://www.atheros.com/"

LICENSE="Atheros"
SLOT="0"
KEYWORDS="*"
IUSE=""

RESTRICT="binchecks"

src_install() {
	insinto /lib/firmware/ar3k
	doins ath3k/files/firmware/ar3k/*.dfu
}
