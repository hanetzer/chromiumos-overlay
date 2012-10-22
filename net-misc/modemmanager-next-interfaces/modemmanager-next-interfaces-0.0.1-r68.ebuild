# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a8803938fc8a3df7b14ba7a2dde3ece0b34d7454"
CROS_WORKON_TREE="9de61ca68a765bedf2e8445331f366f02a618fbe"

# Install the XML interface files for modemmanager-next.  Not part of
# the regular modemmanager-next build because we need these headers
# even if modemmanager-next isn't installed.

EAPI="4"
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
