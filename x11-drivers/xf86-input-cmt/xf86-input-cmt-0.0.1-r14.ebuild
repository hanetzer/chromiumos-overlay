# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3
CROS_WORKON_COMMIT="ee915a19319a4e9a7940e4b0ff11d5cb74a23293"
CROS_WORKON_PROJECT="chromiumos/platform/xf86-input-cmt"

XORG_EAUTORECONF="yes"
BASE_INDIVIDUAL_URI=""
inherit xorg-2 cros-workon

DESCRIPTION="Chromium OS multitouch input driver for Xorg X server."
CROS_WORKON_LOCALNAME="../platform/xf86-input-cmt"

KEYWORDS="arm x86"
LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND="chromeos-base/gestures
	 x11-base/xorg-server
	 x11-libs/mtdev"
DEPEND="${RDEPEND}
	x11-proto/inputproto"

DOCS="README"

# Explicitly call xorg-2_src_prepare, not cros-workon_src_prepare
src_prepare() {
	xorg-2_src_prepare
}
