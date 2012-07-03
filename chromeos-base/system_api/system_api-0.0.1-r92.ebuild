# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=2659de70df19e5a549858c2c3b4044f59d197569
CROS_WORKON_TREE="ba9b3756183b8e0d9acf0b1a1f503404bd9c5662"

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