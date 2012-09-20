# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=b9dc2d1d67eded3518bcad4f61b00b1da3bd2ba4
CROS_WORKON_TREE="0af21b344287fa5ba2e0a050e43b150a10efef1c"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/xf86-input-cmt"

XORG_EAUTORECONF="yes"
BASE_INDIVIDUAL_URI=""
inherit autotools-utils cros-workon

DESCRIPTION="Chromium OS multitouch input driver for Xorg X server."
CROS_WORKON_LOCALNAME="../platform/xf86-input-cmt"

KEYWORDS="arm amd64 x86"
LICENSE="BSD"
SLOT="0"
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

src_install() {
	autotools-utils_src_install
	remove_libtool_files all
}
