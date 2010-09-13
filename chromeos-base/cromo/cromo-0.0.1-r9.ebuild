# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="44a097e500938d8f4bafe5b4734d76c6ef778f25"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chromium OS modem manager"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
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

src_compile() {
	tc-export CXX PKG_CONFIG
	emake PLUGINDIR="${PLUGINDIR}" || die "Failed to compile"
}

src_install() {
	emake DESTDIR=${D} install || die "Install failed"
}
