# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="904f49fd770dd559800523edd91c1226e131655d"
CROS_WORKON_TREE="b15222475d7e97c09e8f8c7ed2761d29ac73eca9"
CROS_WORKON_PROJECT="chromiumos/third_party/dbus-cplusplus"

inherit cros-workon autotools

DESCRIPTION="C++ D-Bus bindings"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/dbus-c%2B%2B"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="1"
KEYWORDS="*"
IUSE="-asan cros_host debug doc +glib"

RDEPEND="
	glib? ( >=dev-libs/dbus-glib-0.76 )
	glib? ( >=dev-libs/glib-2.19:2 )
	>=sys-apps/dbus-1.0
	cros_host? ( >=dev-cpp/ctemplate-2.0 )"
DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt )
	doc? ( app-doc/doxygen )
	virtual/pkgconfig"

src_prepare() {
	if ! use cros_host; then
		# dbusxx-* tools are used to generate XML files from a running dbus
		# interface and generate C++ code from that XML files. They are only
		# interesting while developing a dbus service. Install it only on the
		# host.
		sed -i \
			-e '/^bin_PROGRAMS/s:=.*:=:' \
			tools/Makefile.am || die
	fi
	sed -i \
		-e '/^SUBDIRS/s:=.*:=:' \
		examples/Makefile.am || die
	eautoreconf
}

src_configure() {
	asan-setup-env
	cros-workon_src_configure \
		$(use_enable debug) \
		$(use_enable doc doxygen-docs) \
		$(use_enable glib glib)
}
