# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="e4907644632d293e95235a0e1bd7a8befab2bfc5"
CROS_WORKON_TREE="2c5336144333670d3b5dfec80ab41b0497fab24b"

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
