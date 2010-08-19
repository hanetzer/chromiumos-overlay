# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/ibus-hangul/ibus-hangul-1.2.0.20090617.ebuild,v 1.1 2009/06/18 15:40:05 matsuu Exp $

EAPI="2"
inherit eutils

DESCRIPTION="The Hangul engine for IBus input platform"
HOMEPAGE="http://code.google.com/p/ibus/"
#SRC_URI="http://ibus.googlecode.com/files/${P}.tar.gz"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="nls"

RDEPEND=">=app-i18n/ibus-1.2
	>=app-i18n/libhangul-0.0.10
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	nls? ( >=sys-devel/gettext-0.16.1 )"

src_unpack() {
	unpack ${A}
	cd "${P}"

	# This upstream change is not included in
	# ibus-hangul-1.3.0.20100329.tar.gz yet.
	epatch "${FILESDIR}/ibus-hangul-candidate-window-click-8135d88b75bce61f54d0049e62916420200b38d6.patch"

	# This change will be upstreamed
	# (http://code.google.com/p/ibus/issues/detail?id=1036). For now, we
	# apply it locally to fix http://crosbug.com/4319.
	epatch "${FILESDIR}/ibus-hangul-dont-consume-modifier-keys.patch"
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
	rm "${D}/usr/libexec/ibus-setup-hangul" || die
	rm -rf "${D}/usr/share/ibus-hangul/setup" || die
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	ewarn "This package is very experimental, please report your bugs to"
	ewarn "http://ibus.googlecode.com/issues/list"
	elog
	elog "You should run ibus-setup and enable IM Engines you want to use!"
	elog
}
