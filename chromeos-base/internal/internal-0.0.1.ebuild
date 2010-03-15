# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"

inherit autotools base eutils linux-info

DESCRIPTION="This package is for hooking up your internal overlays"
LICENSE="BSD"
HOMEPAGE="http://src.chromium.org"
SLOT="0"
KEYWORDS="x86 amd64 arm"

DEPEND=""
RDEPEND=""

src_unpack() {
    elog "Meta Package: Nothing to unpack."
}

src_compile() {
    elog "Meta Package: Nothing to compile."
}

src_install() {
    elog "Meta Package: Nothing to install."
}
