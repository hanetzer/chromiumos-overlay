# Copyright 1999-2011 Gentoo Foundation

EAPI="3"

DESCRIPTION="Zinnia learning data for traditional Chinese"
HOMEPAGE="http://tegaki.org/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.zip"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

RDEPEND="app-i18n/zinnia"

src_install() {
	mkdir -p "${D}/usr/share/tegaki/models/zinnia" || die
	install handwriting-zh_TW.meta handwriting-zh_TW.model \
		"${D}/usr/share/tegaki/models/zinnia/" || die
}
