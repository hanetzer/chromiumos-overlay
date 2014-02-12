# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="d4d575e3bf3d879880c078e0e3d79efa7bb5a106"
CROS_WORKON_TREE="b45b946a6f52c351f2d36dfea703c5877501536d"
CROS_WORKON_PROJECT="chromiumos/platform/mtplot"
inherit autotools cros-workon

DESCRIPTION="Multitouch Contact Plotter"
CROS_WORKON_LOCALNAME="../platform/mtplot"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"
RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}
