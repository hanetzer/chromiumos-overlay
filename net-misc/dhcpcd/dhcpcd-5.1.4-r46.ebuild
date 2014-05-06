# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dhcpcd/dhcpcd-5.2.1.ebuild,v 1.1 2010/03/02 18:14:07 williamh Exp $

EAPI=4
CROS_WORKON_COMMIT="d0771404e5c1118c95a175b9a0927189669e6235"
CROS_WORKON_TREE="43d38af5ee10033e75ca1de4a334ce2c12050e5b"
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

pkg_setup() {
	enewuser "dhcp"
	enewgroup "dhcp"
}

src_install() {
	emake DESTDIR="${D}" install
}
