# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon toolchain-funcs

DESCRIPTION="Chromium OS modem manager"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
PLUGINDIR="/usr/lib/cromo/plugins"
DBUSDATADIR="/etc/dbus-1/system.d"

RDEPEND="chromeos-base/libchrome
	>=dev-libs/glib-2.0
	dev-libs/dbus-glib
	dev-libs/dbus-c++
	dev-cpp/gflags
   dev-cpp/glog"
DEPEND="${RDEPEND}
	net-misc/modemmanager"

# Don't strip, since plugins need to resolve symbols
# in the cromo executable
RESTRICT="strip"

src_compile() {
	tc-export CXX PKG_CONFIG
	emake PLUGINDIR="${PLUGINDIR}" || die "Failed to compile"
}

src_install() {
	emake DESTDIR=${D} install || die "Install failed"
}
