# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="d120fb04866b3c0ab9696780b9b606ceffd87352"
CROS_WORKON_TREE="d3ac02c15d68338e40906d8df268553934a0a819"

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
	>=chromeos-base/kernel-headers-2.6.38
	x11-proto/inputproto"

DOCS="README"

src_prepare() {
	eautoreconf
}

src_install() {
	autotools-utils_src_install
	remove_libtool_files all
}
