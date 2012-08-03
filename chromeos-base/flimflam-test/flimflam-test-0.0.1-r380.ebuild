CROS_WORKON_COMMIT=5cb0316cadc25287c5f0186ebe99eb8ee76c78ba
CROS_WORKON_TREE="b8904a3c5938f5500a8581ad569098865f8699c3"

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/connman/connman-0.43.ebuild,v 1.1 2009/10/05 12:22:24 dagger Exp $

EAPI="2"
CROS_WORKON_PROJECT="chromiumos/platform/flimflam"

inherit autotools cros-workon toolchain-funcs

DESCRIPTION="flimflam's test scripts"
HOMEPAGE="http://connman.net"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/flimflam
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject
	net-dns/dnsmasq
	sys-apps/iproute2"

DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="../third_party/flimflam"

src_install() {
	exeinto /usr/lib/flimflam/test
	doexe test/* || die
	cp -rv test/swindle ${D}/usr/lib/flimflam/test/swindle
}
