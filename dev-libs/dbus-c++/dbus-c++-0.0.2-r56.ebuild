# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f140c0aa430e1db1c0f31d23d3eb2397d47f209e"
CROS_WORKON_TREE="04ad60f8ab34992d8b0ef8927f83c6200e4c7470"
CROS_WORKON_PROJECT="chromiumos/third_party/dbus-cplusplus"

inherit cros-workon autotools

DESCRIPTION="C++ D-Bus bindings"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/dbus-c%2B%2B"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="1"
KEYWORDS="*"
IUSE="-asan -clang cros_host debug doc +glib"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	glib? ( >=dev-libs/dbus-glib-0.76 )
	glib? ( >=dev-libs/glib-2.19:2 )
	>=sys-apps/dbus-1.0
	cros_host? ( >=dev-cpp/ctemplate-1.0 )"
DEPEND="${DEPEND}
	doc? ( dev-libs/libxslt )
	doc? ( app-doc/doxygen )
	virtual/pkgconfig
	>=dev-cpp/ctemplate-1.0"

src_prepare() {
	eautoreconf
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure \
		$(use_enable debug) \
		$(use_enable doc doxygen-docs) \
		$(use_enable glib glib)
}
