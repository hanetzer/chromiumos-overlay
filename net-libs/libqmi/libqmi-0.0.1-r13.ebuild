# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Based on gentoo's modemmanager ebuild

EAPI="4"
CROS_WORKON_COMMIT="c0e4ee3f31dc6b0b96ba6459bf67b1b597dd0d10"
CROS_WORKON_TREE="308ba67d6f8bbc704e2091d7b81e4d860eeba814"
CROS_WORKON_PROJECT="chromiumos/third_party/libqmi"

inherit eutils autotools cros-workon

DESCRIPTION="QMI modem protocol helper library"
HOMEPAGE="http://cgit.freedesktop.org/libqmi/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="doc static-libs test"

RDEPEND=">=dev-libs/glib-2.32"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	virtual/pkgconfig"

src_prepare() {
	gtkdocize
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable static{-libs,}) \
		$(use_enable {,gtk-}doc) \
		$(use_with test{,s})
}

src_install() {
	default
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/libqmi-glib.la
}
