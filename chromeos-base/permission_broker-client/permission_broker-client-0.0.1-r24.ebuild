# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="be3e2f61d4a5cc1c2e2d682a397fdbaf132da2bb"
CROS_WORKON_TREE="3b58b8287eb3fc851d2eeaabdd326dc12aabcd09"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="${PN%-client}"
PLATFORM_GYP_FILE="${PN}.gyp"

inherit cros-workon platform

DESCRIPTION="Permission Broker DBus client library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
	local client_includes=/usr/include/permission_broker-client
	local client_test_includes=/usr/include/permission_broker-client-test

	# Install DBus proxy header.
	insinto "${client_includes}/permission_broker"
	doins "${OUT}/gen/include/permission_broker/dbus-proxies.h"
	insinto "${client_test_includes}/permission_broker"
	doins "${OUT}/gen/include/permission_broker/dbus-mocks.h"

	# Generate and install pkg-config for client libraries.
	insinto "/usr/$(get_libdir)/pkgconfig"
	./generate_pc_file.sh "${OUT}" libpermission_broker-client "${client_includes}"
	doins "${OUT}/libpermission_broker-client.pc"
	./generate_pc_file.sh "${OUT}" libpermission_broker-client-test "${client_test_includes}"
	doins "${OUT}/libpermission_broker-client-test.pc"
}
