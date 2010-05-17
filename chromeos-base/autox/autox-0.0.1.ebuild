# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="AutoX library for interacting with X apps"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="dev-python/python-xlib"
DEPEND=

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	mkdir -p "${S}/autox"
	cp -a "${platform}/autox" "${S}" || die
}

src_install() {
	insinto "/usr/lib/python2.6/site-packages"
	doins "autox/autox.py"
}
