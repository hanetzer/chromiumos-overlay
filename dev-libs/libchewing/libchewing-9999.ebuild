# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libchewing/libchewing-0.3.2.ebuild,v 1.2 2010/03/02 10:33:53 fauli Exp $

inherit multilib

DESCRIPTION="Library for Chinese Phonetic input method"
HOMEPAGE="http://chewing.csie.net/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc x86"
IUSE="debug test"

RDEPEND="sys-libs/ncurses"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	test? ( >=dev-libs/check-0.9.4 )"

# Chromium OS changes:
# - Add src_unpack().

src_unpack() {
	local third_party="${CHROMEOS_ROOT}/src/third_party"
	local chewing="${third_party}/libchewing/files"
	elog "Using libchewing dir: $chewing"
	mkdir -p "${S}"
	cp -a "${chewing}"/* "${S}" || die
}

src_compile() {
	./autogen.sh || die
	export CC_FOR_BUILD="${HOSTCC}"
	econf $(use_enable debug) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS README TODO
}

pkg_postinst() {
	if [[ -e "${ROOT}"/usr/$(get_libdir)/libchewing.so.1 ]] ; then
		elog "You must re-compile all packages that are linked against"
		elog "<libchewing-0.2.7 by using revdep-rebuild from gentoolkit:"
		elog "# revdep-rebuild --library libchewing.so.1"
	fi

	if [[ -e "${ROOT}"/usr/$(get_libdir)/libchewing.so.2 ]] ; then
		elog "You must re-compile all packages that are linked against"
		elog "<libchewing-0.3.0 by using revdep-rebuild from gentoolkit:"
		elog "# revdep-rebuild --library libchewing.so.2"
	fi
}
