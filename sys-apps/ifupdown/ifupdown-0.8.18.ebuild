# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils

DESCRIPTION="ifupdown (/etc/network/interfaces support) from Debian"
HOMEPAGE="http://packages.qa.debian.org/i/ifupdown.html"
SRC_URI="mirror://debian/pool/main/i/${PN}/${PN}_${PV}.tar.xz"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/${PN}"

RDEPEND="sys-apps/debianutils"

src_prepare() {
	epatch "${FILESDIR}"/*.patch
}

src_install() {
	into /
	dosbin ifup ifdown ifquery

	insinto /etc/init
	doins "${FILESDIR}"/*.conf

	dodir /etc/network/interfaces.d/
	dodir /etc/network/if-pre-up.d
	dodir /etc/network/if-up.d
	dodir /etc/network/if-down.d/
	dodir /etc/network/if-post-down.d/

	doman interfaces.5 ifup.8 ifdown.8 ifquery.8
}
