# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit eutils

DESCRIPTION="Python test scripts for controlling connman"
HOMEPAGE="http://connman.net"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RESTRICT=""

DEPEND=""
RDEPEND="dev-lang/python"

src_install() {
    local third_party="${CHROMEOS_ROOT}/src/third_party"
    local files="${third_party}/flimflam/files/test"
    dodir /usr/local/lib/connman/test || die
    cp -ar "${files}"/* "${D}"/usr/local/lib/connman/test || die
}
