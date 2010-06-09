# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dhcpcd/dhcpcd-5.2.1.ebuild,v 1.1 2010/03/02 18:14:07 williamh Exp $

EAPI=2

DESCRIPTION="A fully featured, yet light weight RFC2131 compliant DHCP client"
HOMEPAGE="http://roy.marples.name/projects/dhcpcd/"
#SRC_URI not defined because we have local source
LICENSE="BSD-2"

SLOT="0"
KEYWORDS="~amd64 arm x86"
IUSE=""

RDEPEND=">=sys-apps/dbus-1.2"
DEPEND="${RDEPEND}"

src_unpack() {
	if [ -n "$CHROMEOS_ROOT" ] ; then
		local third_party="${CHROMEOS_ROOT}/src/third_party"
		local dhcpcd="${third_party}/dhcpcd"
		elog "Using dhcpcd= dir: $dhcpcd"
		mkdir -p "${S}"
		cp -a "${dhcpcd}"/* "${S}" || die
	else
		unpack ${A}
	fi
	cd "${S}"
}

src_configure() {
	econf --prefix= --libexecdir=/lib/dhcpcd --dbdir=/var/lib/dhcpcd \
		--localstatedir=/var
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
