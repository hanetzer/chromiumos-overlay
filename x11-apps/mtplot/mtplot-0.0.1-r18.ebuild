# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="c33fbd045759dfb0e8a36fc47ba99b1b3aeced59"
CROS_WORKON_TREE="df3cd7cc850f5b27983fa63a616775569e1ee257"

EAPI=4

CROS_WORKON_PROJECT="chromiumos/platform/mtplot"
inherit autotools cros-workon

DESCRIPTION="Multitouch Contact Plotter"
CROS_WORKON_LOCALNAME="../platform/mtplot"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""
RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}
