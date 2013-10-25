# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/wireless-regdb/wireless-regdb-20091125.ebuild,v 1.1 2009/11/26 11:46:13 chainsaw Exp $

EAPI="4"

inherit eutils multilib

MY_P="wireless-regdb-${PV:0:4}.${PV:4:2}.${PV:6:2}"
DESCRIPTION="Binary regulatory database for CRDA"
HOMEPAGE="http://wireless.kernel.org/en/developers/Regulatory"
SRC_URI="http://wireless.kernel.org/download/wireless-regdb/${MY_P}.tar.bz2"
LICENSE="as-is"
SLOT="0"

KEYWORDS="amd64 arm ppc x86 ~amd64-linux ~x86-linux"
IUSE=""

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/regdb-id-5ghz.patch
	epatch "${FILESDIR}"/regdb-ar-5ghz.patch
}

src_compile() {
	emake -j1 REGDB_AUTHOR=chromium
}

src_install() {
	insinto /usr/$(get_libdir)/crda/; doins regulatory.bin
	insinto /usr/$(get_libdir)/crda/pubkeys; doins chromium.key.pub.pem
	doman regulatory.bin.5
	dodoc README db.txt
}
