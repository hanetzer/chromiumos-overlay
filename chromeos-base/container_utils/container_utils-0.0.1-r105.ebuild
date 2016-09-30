# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="8f805c56d40a41ea231c5e9fdcc6a8c42386c612"
CROS_WORKON_TREE="e686ca28050aba28e00f5b8f3430b79f7f4398bd"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
PLATFORM_SUBDIR="container_utils"

inherit cros-workon platform

DESCRIPTION="Helper utilities for generic containers"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/permission_broker
	dev-libs/dbus-c++
"
DEPEND="${RDEPEND}"

src_install() {
	cd "${OUT}"
	dobin broker_service
	cd "${S}"
	insinto /etc/init
	doins broker-service.conf
	doins broker-service-pre-upstart-socket-bridge.conf
	doins broker-service-post-upstart-socket-bridge.conf
}
