# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f5bb1053b80ac2d00dbb0928aa1825fa5ca5b6fd"
CROS_WORKON_TREE="525db96e73df756817d8aba50c120f9ddc99faaf"
CROS_WORKON_PROJECT="chromiumos/third_party/libmbim"

inherit autotools cros-workon multilib

DESCRIPTION="MBIM modem protocol helper library"
HOMEPAGE="http://cgit.freedesktop.org/libmbim/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang doc static-libs"
REQUIRED_USE="asan? ( clang )"

RDEPEND=">=dev-libs/glib-2.32
	>=sys-fs/udev-147[gudev]"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	virtual/pkgconfig"

src_prepare() {
	gtkdocize
	eautoreconf
}

src_configure() {
	clang-setup-env

	# Disable the unused function check as libmbim has auto-generated
	# functions that may not be used.
	append-flags -Xclang-only=-Wno-unused-function
	econf \
		$(use_enable static{-libs,}) \
		$(use_enable {,gtk-}doc)
}

src_test() {
	# TODO(benchan): Run unit tests for arm via qemu-arm.
	[[ "${ARCH}" != "arm" ]] && emake check
}

src_install() {
	default
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/libmbim-glib.la
}
