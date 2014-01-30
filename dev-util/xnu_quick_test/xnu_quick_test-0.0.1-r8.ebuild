# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="5d49db0d1e627a60c3d7de8982281fe5a28272f8"
CROS_WORKON_TREE="7115ae639ccd15b8e67372eec9431d5aa84b1d26"
CROS_WORKON_PROJECT="chromiumos/platform/xnu_quick_test"
CROS_WORKON_LOCALNAME="../platform/xnu_quick_test"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Simple kernel regression test suite"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install
	echo "Not convinced where this should be installed yet."
}
