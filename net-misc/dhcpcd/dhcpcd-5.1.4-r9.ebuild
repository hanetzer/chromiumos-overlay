# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dhcpcd/dhcpcd-5.2.1.ebuild,v 1.1 2010/03/02 18:14:07 williamh Exp $

EAPI=2
CROS_WORKON_COMMIT="1333ff1277c5129e8c14055ad90bcf7245e34603"

inherit cros-workon

DESCRIPTION="A fully featured, yet light weight RFC2131 compliant DHCP client"
HOMEPAGE="http://roy.marples.name/projects/dhcpcd/"
LICENSE="BSD-2"

SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="crash"

RDEPEND=">=sys-apps/dbus-1.2
	crash? ( chromeos-base/crash-dumper )"
DEPEND="${RDEPEND}"

if ! use crash; then
	export LIBCRASH=""
fi

src_configure() {
	econf --prefix= \
		--libexecdir=/lib/dhcpcd \
		--dbdir=/var/lib/dhcpcd \
		--localstatedir=/var --
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
