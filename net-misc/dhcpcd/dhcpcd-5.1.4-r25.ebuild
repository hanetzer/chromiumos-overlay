# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dhcpcd/dhcpcd-5.2.1.ebuild,v 1.1 2010/03/02 18:14:07 williamh Exp $
CROS_WORKON_COMMIT="d390ef100b42b7d58a8c59c13b3f6dca7eeb3232"
CROS_WORKON_TREE="99f241370cb45168a47d8e3d5f950a4292b323c6"

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
