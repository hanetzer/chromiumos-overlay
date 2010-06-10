# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit cros-workon

DESCRIPTION="The xkb-layouts engine IMEngine for IBus Framework"
HOMEPAGE="http://github.com/suzhe/ibus-xkb-layouts"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND=">=app-i18n/ibus-1.2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/gettext-0.16.1"

CROS_WORKON_SUBDIR="files"

src_prepare() {
	NOCONFIGURE=1 ./autogen.sh
}

src_configure() {
	# Since X for Chrome OS does not use evdev, we use xorg.xml.
	econf --with-xkb-rules-xml=/usr/share/X11/xkb/rules/xorg.xml || die
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS README
}
