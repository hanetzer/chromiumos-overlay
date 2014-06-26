# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dhcpcd/dhcpcd-5.2.1.ebuild,v 1.1 2010/03/02 18:14:07 williamh Exp $

EAPI=4
CROS_WORKON_COMMIT="ad9a660665c7c4b6a72d63e93163fed9d3e3cbfd"
CROS_WORKON_TREE="515a30e74c553dd9d9f861e6523cd44d28b89860"
CROS_WORKON_PROJECT="chromiumos/third_party/dhcpcd"

inherit cros-workon user

DESCRIPTION="A fully featured, yet light weight RFC2131 compliant DHCP client"
HOMEPAGE="http://roy.marples.name/projects/dhcpcd/"
LICENSE="BSD-2"

SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND=">=sys-apps/dbus-1.2"
DEPEND="${RDEPEND}"

src_configure() {
	clang-setup-env
	cros-workon_src_configure --prefix= \
		--libexecdir=/lib/dhcpcd \
		--dbdir=/var/lib/dhcpcd \
		--rundir=/var/run/dhcpcd --
}

src_compile() {
	emake
}

pkg_preinst() {
	enewuser "dhcp"
	enewgroup "dhcp"
}
