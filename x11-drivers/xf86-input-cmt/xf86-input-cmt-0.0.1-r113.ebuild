# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c8b0b19946970ac85581fcc2c4ebbd6411e73f68"
CROS_WORKON_TREE="021f4d41847df7f70e79e7975be43dc49a9e9e4c"
CROS_WORKON_PROJECT="chromiumos/platform/xf86-input-cmt"
CROS_WORKON_LOCALNAME="../platform/xf86-input-cmt"

inherit autotools-utils cros-workon

DESCRIPTION="Chromium OS multitouch input driver for Xorg X server"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/gestures
	chromeos-base/libevdev
	x11-base/xorg-server"
DEPEND="${RDEPEND}
	x11-proto/inputproto"

DOCS="README"

src_prepare() {
	eautoreconf
}

src_configure() {
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install
	remove_libtool_files all
}
