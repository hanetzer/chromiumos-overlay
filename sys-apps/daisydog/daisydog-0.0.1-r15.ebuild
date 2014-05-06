# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="6d62c48ac1f0d021aa8318ef7861c746c9094b74"
CROS_WORKON_TREE="0bd9636fdbb82d4a0e531b8b62320358331810cc"
CROS_WORKON_PROJECT="chromiumos/third_party/daisydog"

inherit cros-constants cros-workon toolchain-funcs user

DESCRIPTION="Simple HW watchdog daemon"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_configure() {
	cros-workon_src_configure
	tc-export CC
}

pkg_preinst() {
	enewuser watchdog
	enewgroup watchdog
}
