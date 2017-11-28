# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="9fc050cc68caf92969590f46ca6f9b2f51343feb"
CROS_WORKON_TREE="a69e29dab3a723cf6b275ccbd31e502c696e0f4c"
CROS_WORKON_PROJECT="chromiumos/third_party/libqmi"

inherit autotools cros-workon

DESCRIPTION="QMI modem protocol helper library"
HOMEPAGE="http://cgit.freedesktop.org/libqmi/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-asan doc mbim static-libs"

RDEPEND=">=dev-libs/glib-2.36
	mbim? ( >=net-libs/libmbim-1.14.0 )"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	virtual/pkgconfig"

src_prepare() {
	gtkdocize
	eautoreconf
}

src_configure() {
	asan-setup-env

	# Disable the unused function check as libqmi has auto-generated
	# functions that may not be used.
	append-flags -Xclang-only=-Wno-unused-function
	econf \
		--enable-qmi-username='modem' \
		$(use_enable mbim mbim-qmux) \
		$(use_enable static{-libs,}) \
		$(use_enable {,gtk-}doc)
}

src_test() {
	# TODO(benchan): Run unit tests for non-x86 platforms via qemu.
	[[ "${ARCH}" == "x86" || "${ARCH}" == "amd64" ]] && emake check
}

src_install() {
	default
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/libqmi-glib.la
}
