# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/xnu_quick_test"
CROS_WORKON_LOCALNAME="../platform/xnu_quick_test"

inherit toolchain-funcs cros-workon

DESCRIPTION="Simple kernel regression test suite"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

src_compile() {
	tc-export CC
	emake
}

src_install() {
	echo "Not convinced where this should be installed yet."
}
