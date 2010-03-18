# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils git

DESCRIPTION="This is the SVox Pico speech synthesis library."
HOMEPAGE="http://www.svox.com"
SRC_URI=""
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""
EGIT_REPO_URI="http://android.git.kernel.org/platform/external/svox.git"
EGIT_TREE="196be3b6348f4a6c975d25dbee135fc3952e0ac7"

src_unpack() {
	git_src_unpack
	mkdir -p "${S}/data"

	cp -a "${FILESDIR}"/Makefile "${S}" || die "Cannot copy Makefile"
	cp -rf "${S}"/pico/lib/* "${S}"/
	cp -rf "${S}"/pico/lang/*.bin "${S}"/data/

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
