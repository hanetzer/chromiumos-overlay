# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/autox"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit python cros-workon

DESCRIPTION="AutoX library for interacting with X apps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

RDEPEND="dev-python/python-xlib"
DEPEND=""

pkg_setup() {
	python_pkg_setup
	cros-workon_pkg_setup
}

src_install() {
	insinto "$(python_get_sitedir)"
	doins autox.py
}
