# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="1b0778c7d5785ea35515cc3f5a683b29b875b520"
CROS_WORKON_TREE="231425d8f988422cfc461117674c29caa5ed63d5"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/system_api"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

# Likewise, block libchromeos-0.0.1-r78 or older, that installs
# dbus/service_constants.h. TODO(satorux): Remove this after a month.
RDEPEND="!<=chromeos-base/libchromeos-0.0.1-r78"

DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_install() {
	insinto /usr/include/cros
	doins window_manager/chromeos_wm_ipc_enums.h

	insinto /usr/include/chromeos/dbus
	doins dbus/*.h
	doins dbus/*.proto
}