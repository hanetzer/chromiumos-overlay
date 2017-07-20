# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="9219ab4f799cd7038234938cbe48318e81baa8e7"
CROS_WORKON_TREE="b7373935b4274878e2107830da6e02d7fce88a80"
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
