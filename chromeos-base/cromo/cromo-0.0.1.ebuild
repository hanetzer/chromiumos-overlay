# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

# TODO(jglasgow): setup 9999 functionality
inherit toolchain-funcs

DESCRIPTION="Chromium OS modem manager"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="test"
PLUGINDIR="/usr/lib/cromo/plugins"
DBUSDATADIR="/etc/dbus-1/system.d"

RDEPEND=">=dev-libs/glib-2.0
	dev-libs/dbus-glib
	dev-libs/dbus-c++
	dev-cpp/gflags"
DEPEND="${RDEPEND}
	net-misc/modemmanager
	"

# Don't strip, since plugins need to resolve symbols
# in the cromo executable
RESTRICT="strip"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	cp -a "${platform}/cromo" "${S}" || die "Failed to unpack sources"
}

src_compile() {
	tc-export CXX PKG_CONFIG
	emake PLUGINDIR="${PLUGINDIR}" || die "Failed to compile"
}

src_install() {
	emake DESTDIR=${D} install || die "Install failed"
}
