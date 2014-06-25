# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit python eutils

DESCRIPTION="GYP, a tool to generates native build files."
HOMEPAGE="http://code.google.com/p/gyp/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-svn-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

src_prepare() {
	epatch "${FILESDIR}"/${P}-shlex-split-fix.patch
}

src_install() {
	dobin gyp
	insinto "/usr/$(get_libdir)/python$(python_get_version)/site-packages"
	doins -r pylib/gyp
}
