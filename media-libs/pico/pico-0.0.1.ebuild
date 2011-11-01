# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit toolchain-funcs

DESCRIPTION="the SVox Pico speech synthesis library"
HOMEPAGE="http://www.svox.com/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-${PV}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	mkdir -p "${S}/data"

	cp -a "${FILESDIR}"/Makefile "${S}" || die
	cp -rf "${S}"/pico/lib/* "${S}"/ || die
	cp -rf "${S}"/pico/lang/*.bin "${S}"/data/ || die

	rm -rf "${S}"/pico
	rm -rf "${S}"/picolanginstaller
	rm -f "${S}"/Android.mk
}

src_prepare() {
	tc-export AR CC RANLIB
}

src_install() {
	dolib.a libpico.a || die
	insinto /usr/include/pico
	doins *.h || die
	insinto /usr/share/tts/pico
	doins data/* || die
}
