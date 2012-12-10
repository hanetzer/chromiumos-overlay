# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="591514a4e92bd669d1d0ce18648f4e9e2a2ffd77"
CROS_WORKON_TREE="a78346ac30009c6891fe2172cb18f7fbc2ddb4bb"
CROS_WORKON_PROJECT="chromiumos/third_party/daisydog"

inherit cros-workon toolchain-funcs

DESCRIPTION="Simple HW watchdog daemon"
HOMEPAGE="http://git.chromium.org/gitweb/?p=chromiumos/third_party/daisydog.git"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_configure() {
	tc-export CC
}
