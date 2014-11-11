# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/iperf/iperf-2.0.4.ebuild,v 1.11 2010/01/07 15:48:39 fauli Exp $

EAPI=5
inherit base

DESCRIPTION="tool to measure IP bandwidth using UDP or TCP"
HOMEPAGE="http://iperf.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="as-is"
SLOT="2"
KEYWORDS="*"
IUSE="ipv6 threads debug"

DEPEND=""
RDEPEND="!net-misc/iperf:0"

PATCHES=( "${FILESDIR}"/${PN}-so_linger.patch )
DOCS="INSTALL README"

src_configure() {
	econf \
		$(use_enable ipv6) \
		$(use_enable threads) \
		$(use_enable debug debuginfo)
}

src_install() {
	default
	dohtml doc/*
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
}
