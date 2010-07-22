# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# TODO(msb): move this ebuild to net-dns/minifakedns
EAPI=2
CROS_WORKON_COMMIT="421940b7407669a531d5f45243bd79114684c39f"
inherit cros-workon

DESCRIPTION="Minimal python dns server"
HOMEPAGE="http://code.activestate.com/recipes/491264-mini-fake-dns-server/"
LICENSE="PSF"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="dev-lang/python"

DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="../third_party/miniFakeDns"

src_install() {
	insinto "/usr/lib/python2.6/site-packages"
	doins "src/miniFakeDns.py"
}
