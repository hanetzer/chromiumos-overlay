# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="9b16b77ecba2b061d57be3d6c05a30a0ec9b89ca"
CROS_WORKON_TREE="0f5d7ea3958ba00b194752ef7af7033e7efa9e9e"

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
