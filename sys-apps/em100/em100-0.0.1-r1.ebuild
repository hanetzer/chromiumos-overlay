# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
CROS_WORKON_COMMIT="6e60dbae5bf62cd0ffffb9fc5ca9ba93e831ee88"
CROS_WORKON_TREE="97435507f8438925686bcf74db3e4e1fe9a1b8ee"
CROS_WORKON_PROJECT="chromiumos/third_party/em100"

inherit cros-workon toolchain-funcs

DESCRIPTION="A simple utility to control a Dediprog EM100pro from Linux"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

DEPEND="virtual/libusb:1"
RDEPEND="${DEPEND}"

src_compile() {
	tc-export CC PKG_CONFIG

	emake
}

src_install() {
	dosbin em100
}
