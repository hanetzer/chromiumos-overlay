# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="da3432610a04048db551cb99013aa3fd2f113b37"
CROS_WORKON_TREE="9e807396ad7f9cc054054bd76122a3a016090f7e"
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
