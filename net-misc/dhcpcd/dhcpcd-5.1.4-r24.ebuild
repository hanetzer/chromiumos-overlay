# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dhcpcd/dhcpcd-5.2.1.ebuild,v 1.1 2010/03/02 18:14:07 williamh Exp $
CROS_WORKON_COMMIT="7508c41b9362fcb6beea872f45a72fa99aa39daf"
CROS_WORKON_TREE="7a32b25b8d799faa0791f3042c263841f8b37afd"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/dhcpcd"

inherit cros-workon

DESCRIPTION="A fully featured, yet light weight RFC2131 compliant DHCP client"
HOMEPAGE="http://roy.marples.name/projects/dhcpcd/"
LICENSE="BSD-2"

SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND=">=sys-apps/dbus-1.2"
DEPEND="${RDEPEND}"

src_configure() {
	econf --prefix= \
		--libexecdir=/lib/dhcpcd \
		--dbdir=/var/lib/dhcpcd \
		--rundir=/var/run/dhcpcd --
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
