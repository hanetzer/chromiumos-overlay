# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5e4f631e633384751f582bd9db5f4d6eb2112494"
CROS_WORKON_TREE="6c16783afa179d7e5f0163355876233a78677b87"
CROS_WORKON_PROJECT="chromiumos/platform/mtplot"
CROS_WORKON_LOCALNAME="../platform/mtplot"

inherit autotools cros-workon

DESCRIPTION="Multitouch Contact Plotter"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"
RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}
