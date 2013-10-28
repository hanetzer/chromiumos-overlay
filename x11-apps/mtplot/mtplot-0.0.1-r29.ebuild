# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="18125b556c0197ae696894b9558f08d0b69c584c"
CROS_WORKON_TREE="2f06c03fb22e2aa2f8b0fbb0f2ce58b94372f4d6"
CROS_WORKON_PROJECT="chromiumos/platform/mtplot"
inherit autotools cros-workon

DESCRIPTION="Multitouch Contact Plotter"
CROS_WORKON_LOCALNAME="../platform/mtplot"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
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
