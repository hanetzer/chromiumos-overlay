# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="1fe0c88b3e1ce3d0b80c80c760582d4983d62554"
CROS_WORKON_TREE="dbc2b31a29a88b9e9c9972189c0e967d1be7e6bd"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="peerd"

inherit cros-workon platform user

DESCRIPTION="Local peer discovery services for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
	net-dns/avahi-daemon
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

pkg_preinst() {
	# Create user and group for peerd.
	enewuser "peerd"
	enewgroup "peerd"
}

src_install() {
	dobin "${OUT}/peerd"
	# Install init scripts.
	insinto /etc/init
	doins init/peerd.conf
	# Install DBus configuration files.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.peerd.conf

	local client_includes=/usr/include/peerd-client
	local client_test_includes=/usr/include/peerd-client-test

	# Install DBus proxy headers
	insinto "${client_includes}/peerd"
	doins "${OUT}/gen/include/peerd/dbus-proxies.h"
	insinto "${client_test_includes}/peerd"
	doins "${OUT}/gen/include/peerd/dbus-proxy-mocks.h"

	# Install pkg-config for client libraries.
	./generate_pc_file.sh "${OUT}" libpeerd-client "${client_includes}"
	./generate_pc_file.sh "${OUT}" libpeerd-client-test "${client_test_includes}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}/libpeerd-client.pc"
	doins "${OUT}/libpeerd-client-test.pc"
}

platform_pkg_test() {
	local tests=(
		peerd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
