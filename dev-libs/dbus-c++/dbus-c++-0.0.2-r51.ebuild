# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="604df69ed3e7a528be9a91ca7be0fa2b9b180166"
CROS_WORKON_TREE="a12f79223e3f2bee520a015feb7edce3c208909c"
CROS_WORKON_PROJECT="chromiumos/third_party/dbus-cplusplus"

inherit cros-workon autotools

DESCRIPTION="C++ D-Bus bindings"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/dbus-c%2B%2B"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="1"
KEYWORDS="*"
IUSE="-asan -clang debug doc +glib"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	glib? ( >=dev-libs/dbus-glib-0.76 )
	glib? ( >=dev-libs/glib-2.19:2 )
	>=sys-apps/dbus-1.0
	>=dev-cpp/ctemplate-1.0"
DEPEND="${DEPEND}
	doc? ( dev-libs/libxslt )
	doc? ( app-doc/doxygen )
	virtual/pkgconfig"

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
