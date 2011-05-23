# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="This is the SVox Pico speech synthesis library."
HOMEPAGE="http://www.svox.com"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-${PV}.tar.bz2"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

post_src_unpack() {
	mkdir -p "${S}/data"

	cp -a "${FILESDIR}"/Makefile "${S}" || die "Cannot copy Makefile"
	cp -rf "${S}"/pico/lib/* "${S}"/ || die "Cannot copy lib"
	cp -rf "${S}"/pico/lang/*.bin "${S}"/data/ || die "Cannot copy lang"

	rm -rf "${S}"/pico
	rm -rf "${S}"/picolanginstaller
	rm -f "${S}"/Android.mk
}

src_compile() {
	# Use cross-compiler, otherwise a 64-bit binary is created.
	tc-getCC
	tc-getAR
	export CCFLAGS="$CFLAGS"
	emake -j1 || die "emake failed"
}

src_install() {
	insinto /usr/lib
	insopts -m0755
	doins "${S}/libpico.a"
	insinto /usr/include/pico
	doins "${S}/"*.h || die "include install failed"
	insinto /usr/share/tts/pico
	doins "${S}/data/"* || die "data install failed"
}
