# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Install the XML interface files for modemmanager-next.  Not part of
# the regular modemmanager-next build because we need these headers
# even if modemmanager-next isn't installed.

EAPI="4"
CROS_WORKON_COMMIT="677b329d1894ca993121aea670098778f83c6590"
CROS_WORKON_TREE="9c2e641f7aefc0be2e735343f96a22e637009873"
CROS_WORKON_PROJECT="chromiumos/third_party/modemmanager-next"
CROS_WORKON_LOCALNAME="../third_party/modemmanager-next"

inherit autotools cros-workon

DESCRIPTION="DBus interface descriptions and headers for ModemManager v0.6"
HOMEPAGE="http://www.chromium.org/"
#SRC_URI not defined because we get our source locally

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	>=dev-libs/glib-2.30.2
	>=dev-util/gtk-doc-1.13
	>=sys-fs/udev-145[gudev]
	!net-misc/modemmanager-next"

src_prepare () {
	gtkdocize || die "gtkdocize failed"
	eautopoint
	eautoreconf
	intltoolize --force
}

src_compile() {
	# Only build the .h files we need
	emake -C include
}

src_install() {
	insinto /usr/share/dbus-1/interfaces
	doins introspection/org.freedesktop.ModemManager1.*.xml

	insinto /usr/include/mm
	doins include/*.h
}
