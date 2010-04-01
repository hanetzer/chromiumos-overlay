# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Minimal python dns server"
HOMEPAGE="http://code.activestate.com/recipes/491264-mini-fake-dns-server/"
LICENSE="PSF"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="dev-lang/python"

DEPEND="${RDEPEND}"

src_unpack() {
	local third_party="${CHROMEOS_ROOT}/src/third_party"
	local mini_fake_dns="${third_party}/miniFakeDns"
	mkdir -p "${S}"
	cp -a "${mini_fake_dns}"/* "${S}" || die
}

src_install() {
	insinto "/usr/lib/python2.6/site-packages"
	doins "src/miniFakeDns.py"
}
