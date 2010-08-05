# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="8b510c7d95f89c46d8349f9e13eaf5fd422795a0"

inherit cros-workon

DESCRIPTION="AutoX library for interacting with X apps"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="dev-python/python-xlib"
DEPEND=

src_install() {
	insinto /usr/lib/python2.6/site-packages
	doins autox.py
}
