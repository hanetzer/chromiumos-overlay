# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/ibus-pinyin/ibus-pinyin-1.2.0.20090915.ebuild,v 1.1 2009/09/15 15:11:20 matsuu Exp $

EAPI="2"
CROS_WORKON_COMMIT="397ceeb1f64eed0dfdb69c618c9984833bc52e71"
inherit cros-workon eutils flag-o-matic

#PYDB_TAR="pinyin-database-0.1.10.6.tar.bz2"
DESCRIPTION="Chinese PinYin IMEngine for IBus Framework"
HOMEPAGE="http://code.google.com/p/ibus/"
#SRC_URI="http://ibus.googlecode.com/files/${P}.tar.gz
#	http://ibus.googlecode.com/files/${PYDB_TAR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="nls"

# Changes:
# - We don't need the ">=dev-lang/python-2.5[sqlite]" package since we preprocesses
#   ibus-pinyin/files/data/db/android/rawdict_utf16_65105_freq.txt on host OS (Ubuntu).
# - Added dev-db/sqlite-3.6.18 insted. The package is used by C++ files in ibus-pinyin.
# - Modified src_compile(). We have to run autogen.sh before econf.
# - Inherit src_unpack() from cros-workon
#   Open Phrase PinYin DB (pinyin-database-0.1.10.6.tar.bz2) to the source tree.
# - Modified src_install() so emerge removes Python related files.

# TODO(yusukes): Ask someone if we should support Open Phrase DB or not.

RDEPEND=">=app-i18n/ibus-1.1.0
	>=dev-db/sqlite-3.6.18
	nls? ( virtual/libintl )"

DEPEND="${RDEPEND}
	=dev-libs/boost-1.42.0
	dev-util/pkgconfig
	nls? ( >=sys-devel/gettext-0.16.1 )"

CROS_WORKON_SUBDIR="files"

src_unpack() {
	cros-workon_src_unpack
	cd "${S}"
	ln -sf "$(type -P true)" py-compile || die
}

src_prepare() {
	append-flags "-I${SYSROOT}/usr/include/boost-1_42"
	NOCONFIGURE=1 ./autogen.sh
}

src_configure() {
	econf $(use_enable nls) || die
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	# Remove all Python related files
	rm "${D}/usr/libexec/ibus-setup-pinyin" || die
	rm -rf "${D}/usr/share/ibus-pinyin/setup" || die
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	ewarn "This package is very experimental, please report your bugs to"
	ewarn "http://ibus.googlecode.com/issues/list"
	elog
	elog "You should run ibus-setup and enable IM Engines you want to use!"
	elog
}
