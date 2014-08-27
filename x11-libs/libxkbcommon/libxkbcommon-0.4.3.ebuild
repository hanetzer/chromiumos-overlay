# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cros-constants

EGIT_REPO_URI="https://github.com/xkbcommon/libxkbcommon.git"
EGIT_COMMIT="527bf96f9b0a25928432edba4bab27ac808a2fe2"
XORG_EAUTORECONF="yes"

inherit xorg-2 git-2

SRC_URI=""

DESCRIPTION="X.Org xkbcommon library"
KEYWORDS="amd64 arm x86"
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
