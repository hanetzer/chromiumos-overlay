# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apache/mod_wsgi/mod_wsgi-3.4.ebuild,v 1.4 2012/11/21 10:13:37 ago Exp $

EAPI="3"
PYTHON_DEPEND="*"
PYTHON_USE_WITH="threads"

inherit autotools apache-module eutils multilib python toolchain-funcs

DESCRIPTION="An Apache2 module for running Python WSGI applications."
HOMEPAGE="http://code.google.com/p/modwsgi/"
SRC_URI="http://modwsgi.googlecode.com/files/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

APACHE2_MOD_CONF="70_${PN}"
APACHE2_MOD_DEFINE="WSGI"

DOCFILES="README"

need_apache2

src_prepare() {
	epatch "${FILESDIR}/${P}"-SYSROOT.patch
	epatch "${FILESDIR}/${P}"-sbh-pointer-fix.patch
	cp "${SYSROOT}/usr/sbin/apxs" "${T}/apxs"
	# Update apxs to point to the installbuilddir and includedir in the
	# SYSROOT rather than on the build host.
	sed -i -r \
		-e '/^my \$(installbuild|include)dir/s:=:= $ENV{"SYSROOT"} .:' \
		"${T}/apxs" || die
	eautoconf
}

src_configure() {
	econf --prefix="${SYSROOT}" --with-apxs="${T}/apxs"
}

src_compile() {
	default
}
