# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/ibus-m17n/ibus-m17n-1.2.0.20090617.ebuild,v 1.1 2009/06/18 15:40:00 matsuu Exp $

DESCRIPTION="The M17N engine IMEngine for IBus Framework"
HOMEPAGE="http://code.google.com/p/ibus/"
#SRC_URI="http://ibus.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

RDEPEND=">=app-i18n/ibus-1.2
	dev-libs/m17n-lib
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-db/m17n-db
	>=sys-devel/gettext-0.16.1"

# Chromium OS change:
# - Removed dev-db/m17n-contrib from DEPEND for now since we're still not sure
#   if we really need this package.
# - Added src_unpack().
# - Added ./autogen.sh call to src_compile().

src_unpack() {
	if [ -n "$CHROMEOS_ROOT" ] ; then
		local third_party="${CHROMEOS_ROOT}/src/third_party"
		local ibus="${third_party}/ibus-m17n/files"
		elog "Using ibus-m17n dir: $ibus"
		mkdir -p "${S}"
		cp -a "${ibus}"/* "${S}" || die
	else
		unpack ${A}
	fi

	cd "${S}"
}

src_compile() {
	NOCONFIGURE=1 ./autogen.sh
	econf $(use_enable nls) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	ewarn "This package is very experimental, please report your bugs to"
	ewarn "http://ibus.googlecode.com/issues/list"
	elog
	elog "You should run ibus-setup and enable IM Engines you want to use!"
	elog
}
