# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="The xkb-layouts engine IMEngine for IBus Framework"
HOMEPAGE="http://github.com/suzhe/ibus-xkb-layouts"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=app-i18n/ibus-1.2
	 x11-libs/libxklavier"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/gettext-0.16.1"

src_unpack() {
	if [ -n "$CHROMEOS_ROOT" ] ; then
		local third_party="${CHROMEOS_ROOT}/src/third_party"
		local ibus="${third_party}/ibus-xkb-layouts/files"
		elog "Using ibus-xkb-layouts dir: $ibus"
		mkdir -p "${S}"
		cp -a "${ibus}"/* "${S}" || die
	else
		unpack ${A}
	fi

	cd "${S}"
}

src_compile() {
	NOCONFIGURE=1 ./autogen.sh
	econf || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS README
}
