
# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/connman/connman-0.43.ebuild,v 1.1 2009/10/05 12:22:24 dagger Exp $

EAPI="2"
CROS_WORKON_COMMIT="d25f510ba4391da2305d7c47b9f24f3564d64cbd"

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
	dev-python/pygobject"

DEPEND="${RDEPEND}"

CROS_WORKON_PROJECT="flimflam"
CROS_WORKON_LOCALNAME="../third_party/flimflam"

src_install() {
	exeinto /usr/lib/flimflam/test
	doexe test/* || die
	cp -rv test/swindle ${D}/usr/lib/flimflam/test/swindle
}
