# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e33f851cc50bca67281c831fa9b61f8e83748e7b"
CROS_WORKON_TREE="d5b53ffe0c99e633dc7820370f6a0bc01bc8c1ae"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit cros-debug cros-workon libchrome

DESCRIPTION="Touchpad Experimentation Framework"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	sys-libs/ncurses
	x11-libs/libX11
	x11-libs/libXi"
DEPEND="${RDEPEND}
	x11-proto/xproto"

src_unpack() {
	cros-workon_src_unpack
	S+="/salsa"
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cd try_touch_experiment
	cros-workon_src_compile
}

src_install() {
	cd try_touch_experiment
	cros-workon_src_install
	default
}
