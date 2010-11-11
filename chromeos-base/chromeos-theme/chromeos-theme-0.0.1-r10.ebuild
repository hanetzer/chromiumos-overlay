# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="1147ee5cf161a58e25b4aac686e1978bed94c831"

inherit cros-workon multilib
inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS GTK+ Theme."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND="dev-libs/glib
        >=x11-libs/gtk+-2"

RDEPEND="${DEPEND}"

CROS_WORKON_LOCALNAME="theme"
CROS_WORKON_PROJECT="theme"

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export CCFLAGS="$CFLAGS"
	fi

	scons || die "theme compile failed."
}

src_install() {
  dodir /usr/lib/gtk-2.0/2.10.0/engines
  install -m644 -o root -g root "${S}"/libtheme.so \
    "${D}"/usr/$(get_libdir)/gtk-2.0/2.10.0/engines || die

  dodir /usr/share/themes/theme/gtk-2.0
  install -m644 -o root -g root "${S}"/resources/gtkrc \
    "${D}"/usr/share/themes/theme/gtk-2.0 || die
}

pkg_postinst() {
  rm -f "${ROOT}"/etc/gtk-2.0/gtkrc
  ln -s /usr/share/themes/theme/gtk-2.0/gtkrc "${ROOT}"/etc/gtk-2.0/gtkrc
}
