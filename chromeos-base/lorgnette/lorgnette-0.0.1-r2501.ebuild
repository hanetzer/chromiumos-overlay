# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="60ec6e9b89f9463ac5b51542520efa216ce22e09"
CROS_WORKON_TREE=("99d4f98c0151c7e25437bb625f114bde347170d5" "71199b2160a19a264337cb74a8c2f3b27514178a" "413888b8ea9a5695763b620c5ed048a20960333b")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk lorgnette metrics"

PLATFORM_SUBDIR="lorgnette"

inherit cros-workon platform

DESCRIPTION="Document Scanning service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/minijail
	chromeos-base/libbrillo
	chromeos-base/metrics
	media-gfx/sane-backends
	media-gfx/pnm2png
"

DEPEND="${RDEPEND}
	chromeos-base/permission_broker-client
	chromeos-base/system_api
"

src_install() {
	dobin "${OUT}"/lorgnette
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.lorgnette.conf
	insinto /usr/share/dbus-1/system-services
	doins dbus_service/org.chromium.lorgnette.service
}

platform_pkg_test() {
	platform_test "run" "${OUT}/lorgnette_unittest"
}