# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d20e41ca6a90e335b89b7fcc386426f8d21ed259"
CROS_WORKON_TREE="eb5427b81a9bd66b7bcb7d736b2d4223acd814ba"
CROS_WORKON_PROJECT="chromiumos/third_party/libmbim"

inherit autotools cros-workon multilib

DESCRIPTION="MBIM modem protocol helper library"
HOMEPAGE="http://cgit.freedesktop.org/libmbim/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="doc static-libs"

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
		$(use_enable {,gtk-}doc)
}

src_test() {
	# TODO(benchan): Run unit tests for arm via qemu-arm.
	if [[ "${ARCH}" != "arm" ]]; then
		emake GCONV_PATH="${SYSROOT}"/usr/$(get_libdir)/gconv check
	fi
}

src_install() {
	default
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/libmbim-glib.la
}
