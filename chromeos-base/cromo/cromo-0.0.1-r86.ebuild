# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="4cf9f630726c23dad0f1ebe921a548feb5c9d7f4"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chromium OS modem manager"
HOMEPAGE="http://src.chromium.org"
IUSE="install_tests"
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
	dev-cpp/glog
	install_tests? ( dev-cpp/gtest )
	chromeos-base/libchromeos
	chromeos-base/metrics
"

DEPEND="${RDEPEND}
	net-misc/modemmanager"

use install_tests && MAKE_FLAGS="INSTALL_TESTS=1"

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	REV=${CROS_WORKON_COMMIT-unknown}
	if [ "${REV}" = "master" ]; then REV=unknown; fi
	emake ${MAKE_FLAGS} PLUGINDIR="${PLUGINDIR}" VCSID="${REV}" || die "Failed to compile"
}

src_install() {
	emake ${MAKE_FLAGS} DESTDIR=${D} install || die "Install failed"
}
