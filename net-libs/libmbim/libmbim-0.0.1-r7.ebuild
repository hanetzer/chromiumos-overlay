# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="5cb8673d56ccc99e48e8eacbfe84d560d2c66e12"
CROS_WORKON_TREE="7f3c8b99a9419f07d4a0e8ad84ca1ceb3edade05"
CROS_WORKON_PROJECT="chromiumos/third_party/libmbim"

inherit autotools cros-workon multilib

DESCRIPTION="MBIM modem protocol helper library"
HOMEPAGE="http://cgit.freedesktop.org/libmbim/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="doc static-libs"

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
