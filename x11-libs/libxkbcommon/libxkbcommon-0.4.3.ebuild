# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cros-constants

SRC_URI="https://github.com/xkbcommon/libxkbcommon/archive/${P}.tar.bz2"
XORG_EAUTORECONF="yes"

inherit xorg-2

DESCRIPTION="X.Org xkbcommon library"
KEYWORDS="*"
IUSE=""

RDEPEND="x11-proto/xproto
	>=x11-proto/kbproto-1.0.5"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex"

pkg_setup() {
	xorg-2_pkg_setup
	XORG_CONFIGURE_OPTIONS=(
		--disable-x11
	)
}

src_prepare() {
	# http://bugs.gentoo.org/show_bug.cgi?id=386181
	cat <<-\EOF >> makekeys/Makefile.am
	CFLAGS = $(BUILD_CFLAGS)
	CPPFLAGS = $(BUILD_CPPFLAGS)
	LDFLAGS = $(BUILD_LDFLAGS)
	EOF

	xorg-2_src_prepare
}
