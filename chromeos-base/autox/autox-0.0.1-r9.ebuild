# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8b510c7d95f89c46d8349f9e13eaf5fd422795a0"
CROS_WORKON_TREE="eddb60739953b39a30e4a4ec39a11182cac359c1"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/autox"

inherit python cros-workon

DESCRIPTION="AutoX library for interacting with X apps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="dev-python/python-xlib"
DEPEND=

src_install() {
	insinto "$(python_get_sitedir)"
	doins autox.py || die
}
