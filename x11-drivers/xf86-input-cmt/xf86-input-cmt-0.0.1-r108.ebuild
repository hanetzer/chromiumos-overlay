# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="65da5ce91d34b372261d77601afe146690ab45e4"
CROS_WORKON_TREE="025a6e78c5a9562bc505e79364cb6ac6e4fe7fed"
CROS_WORKON_PROJECT="chromiumos/platform/xf86-input-cmt"

XORG_EAUTORECONF="yes"
BASE_INDIVIDUAL_URI=""
inherit autotools-utils cros-workon

DESCRIPTION="Chromium OS multitouch input driver for Xorg X server."
CROS_WORKON_LOCALNAME="../platform/xf86-input-cmt"

KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
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

src_configure() {
	cros-workon_src_configure
}

src_install() {
	autotools-utils_src_install
	remove_libtool_files all
}
