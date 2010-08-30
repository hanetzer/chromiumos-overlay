# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/ibus-m17n/ibus-m17n-1.2.0.20090617.ebuild,v 1.1 2009/06/18 15:40:00 matsuu Exp $

EAPI="2"
inherit eutils

DESCRIPTION="The M17N engine IMEngine for IBus Framework"
HOMEPAGE="http://code.google.com/p/ibus/"
SRC_URI="http://ibus.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="nls"

RDEPEND=">=app-i18n/ibus-1.2
	>=dev-libs/m17n-lib-1.6.1
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	chromeos-base/chromeos-assets
	=dev-db/m17n-contrib-1.1.10
	>=dev-db/m17n-db-1.6.1
	dev-util/pkgconfig
	>=sys-devel/gettext-0.16.1"

src_prepare() {
	# Apply a patch that fixes crosbug.com/4859. The patch is already
	# included in the ibus-m17n upstream repo, but not in the 1.3.0 tarball.
	# https://code.google.com/p/ibus/issues/detail?id=625
	epatch "${FILESDIR}"/0001-Fix-Mtext-gunichar-conversion.patch

	# Build ibus-engine-m17n for the host platform.
	(env -i ./configure && env -i make) || die
	# Obtain the XML output by running the binary.
	src/ibus-engine-m17n --xml > output.xml || die
	# Clean up.
	make distclean || die
}

src_configure() {
	econf $(use_enable nls) || die
}

src_compile() {
	emake || die
	# Rewrite xkb-layouts.xml using the XML output.
	LIST="${SYSROOT}"/usr/share/chromeos-assets/input_methods/whitelist.txt
	python "${FILESDIR}"/filter.py < output.xml \
	--whitelist="${LIST}" \
	--rewrite=src/m17n.xml || die
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
