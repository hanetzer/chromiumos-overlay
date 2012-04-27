# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="fde4893ba475e7e5c03ede7d2d2a830b40db56f5"
CROS_WORKON_TREE="77c7e3dccc7b298af8d781da63eaf66c2c1be57d"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/system_api"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

# The blocker dependency is added to block libcros-0.0.1-r303 or older,
# that installs chromeos_wm_ipc_enums.h, to avoid a collision of the file.
# TODO(satorux): We'll leave this blocker around for at least a month
# so that people running build_packages don't see warnings. Then, we'll
# remove this.
#
# Likewise, block libchromeos-0.0.1-r78 or older, that installs
# dbus/service_constants.h. TODO(satorux): Remove this after a month.
RDEPEND="!<=chromeos-base/libcros-0.0.1-r303
	!<=chromeos-base/libchromeos-0.0.1-r78"

DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_install() {
	insinto /usr/include/cros
	doins window_manager/chromeos_wm_ipc_enums.h

	insinto /usr/include/chromeos/dbus
	doins dbus/*.h
	doins dbus/*.proto
}