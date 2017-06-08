# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a3aeae31bd4c8e1e69a5aef54ef46b73d6dc3c72"
CROS_WORKON_TREE="db9a0ecf976bb663f06c37c2268c015e769eee73"
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
IUSE="-asan"

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
	asan-setup-env
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
