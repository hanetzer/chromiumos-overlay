# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9c023cf430f680093f64c5946021c04f9c4d40f4"
CROS_WORKON_TREE="5946a45e16e3e0b628c9379fc000d81a85c20465"
CROS_WORKON_PROJECT="chromiumos/third_party/daisydog"

inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="Simple HW watchdog daemon"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

src_configure() {
	cros-workon_src_configure
	tc-export CC
}
