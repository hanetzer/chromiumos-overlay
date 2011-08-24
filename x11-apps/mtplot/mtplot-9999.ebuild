# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_PROJECT="chromiumos/platform/mtplot"
XORG_EAUTORECONF="yes"
inherit xorg-2 cros-workon

DESCRIPTION="Multitouch Contact Plotter"
CROS_WORKON_LOCALNAME="../platform/mtplot"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~arm"
IUSE=""
RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"

src_prepare() {
	xorg-2_src_prepare
}
