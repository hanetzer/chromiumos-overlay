# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils multilib

MY_P="wireless-regdb-${PV:0:4}.${PV:4:2}.${PV:6:2}"
DESCRIPTION="Binary regulatory database for CRDA"
HOMEPAGE="http://wireless.kernel.org/en/developers/Regulatory"
SRC_URI="http://www.kernel.org/pub/software/network/${PN}/${MY_P}.tar.xz"
LICENSE="ISC"
SLOT="0"

KEYWORDS="*"
IUSE=""

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/regdb-ar-5ghz.patch
	epatch "${FILESDIR}"/regdb-80mhz-5ghz.patch
	epatch "${FILESDIR}"/regdb-us-unii2e.patch
	epatch "${FILESDIR}"/regdb-world-5ghz.patch
	epatch "${FILESDIR}"/regdb-world-correct-bw.patch
}

src_compile() {
	emake -j1 REGDB_AUTHOR=chromium
}

src_install() {
	# Install into /usr/lib instead of $(get_libdir), since the
	# crda source code has a hard-coded reference to it.
	insinto /usr/lib/crda/
	doins regulatory.bin

	insinto /usr/lib/crda/pubkeys
	doins chromium.key.pub.pem

	doman regulatory.bin.5
	dodoc README db.txt
}
