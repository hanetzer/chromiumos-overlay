# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Based on gentoo's modemmanager ebuild

EAPI="4"
CROS_WORKON_COMMIT="0307f81be3bb8b5d569f8655521cc70a9eed53f8"
CROS_WORKON_TREE="8ed6b18f8d3e56c6824b05229d6db286f11860de"
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
		$(use_with doc{,s}) \
		$(use_with test{,s})
}

src_install() {
	default
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/libqmi-glib.la
}
