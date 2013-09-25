# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a20d30476e9815adae5f5cc1c66c6cc7ed77f3d1"
CROS_WORKON_TREE="1950de292c927d557bd92f6fa7dbb5bbbac31d91"
CROS_WORKON_PROJECT="chromiumos/third_party/daisydog"

inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="Simple HW watchdog daemon"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_configure() {
	cros-workon_src_configure
	tc-export CC
}
