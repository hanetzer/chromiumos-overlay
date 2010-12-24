# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xkeyboard-config/xkeyboard-config-1.7.ebuild,v 1.11 2010/01/19 20:28:30 armin76 Exp $

EAPI="2"
SRC_URI="http://xlibs.freedesktop.org/xkbdesc/${P}.tar.bz2"

inherit autotools eutils

DESCRIPTION="X keyboard configuration database"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/XKeyboardConfig"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

LICENSE="MIT"
SLOT="0"

RDEPEND="x11-apps/xkbcomp"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.30
	dev-libs/glib
	dev-perl/XML-Parser"

src_prepare() {
	# We should not assign modifier keys (Alt_L, Meta_L, and <LWIN>) in
	# symbols/{pc,altwin} since they are assigned in symbols/chromeos.
	epatch "${FILESDIR}/${P}-modifier-keys.patch"

	epatch "${FILESDIR}/${P}-XFER-jp-keyboard.patch"
	epatch "${FILESDIR}/${P}-be-keyboard.patch"
	epatch "${FILESDIR}/${P}-no-keyboard.patch"
	epatch "${FILESDIR}/${P}-symbols-makefile.patch"
	epatch "${FILESDIR}/${P}-backspace-and-arrow-keys.patch"

	# Generate symbols/chromeos.
	python "${FILESDIR}"/gen_symbols_chromeos.py > symbols/chromeos || die

	# Generate symbols/version.
	# TODO(yusukes,jrbarnette): Once the XKB cache issue in the MeeGo patch
	# for X is fixed, we should remove this workaround here. See
	# http://crosbug.com/6261 for details.
	python "${FILESDIR}"/gen_version_files.py --version="${PVR}" \
	       --format="xkb" > symbols/version || die

	# Regenerate symbols/symbols.dir.
	pushd symbols/
	xkbcomp -lfhlpR '*' > symbols.dir || die
	popd
	# Regenerate symbols/Makefile.in from the patched symbols/Makefile.am.
	autoreconf -v --install || die
}

src_configure() {
	econf \
		--with-xkb-base=/usr/share/X11/xkb \
		--enable-compat-rules \
		--disable-xkbcomp-symlink \
		--with-xkb-rules-symlink=xorg \
		|| die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	echo "CONFIG_PROTECT=\"/usr/share/X11/xkb\"" > "${T}"/10xkeyboard-config
	doenvd "${T}"/10xkeyboard-config

	# Generate xkeyboard_config_version.h to let libcros know the version
	# of the xkeyboard-config package. libcros uses the information to
	# generate a keyboard layout name (e.g. "us+chromeos(..)+version(..)".)
	# TODO(yusukes,jrbarnette): We should also remove this header file when
	# the MeeGo patch is fixed.
	python "${FILESDIR}"/gen_version_files.py --version="${PVR}" \
	       --format="cpp" > "${T}/xkeyboard_config_version.h" || die
	insinto /usr/include
	doins "${T}/xkeyboard_config_version.h"
}
