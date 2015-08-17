# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="5f8cd9da992e59c32bc24e3abe1faa434144da21"
CROS_WORKON_TREE="b9058ebbd15886158a45ffddad25b1982dc7fde4"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="firewalld"

inherit cros-workon platform

DESCRIPTION="System service for handling firewall rules in Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	sys-apps/dbus
"

DEPEND="${RDEPEND}
	chromeos-base/permission_broker-client
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	dobin "${OUT}/firewalld"

	# Install D-Bus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Firewalld.conf

	# Install Upstart configuration.
	insinto /etc/init
	doins firewalld.conf

	local client_includes=/usr/include/firewalld-client
	local client_test_includes=/usr/include/firewalld-client-test

	# Install DBus proxy header.
	insinto "${client_includes}/firewalld"
	doins "${OUT}/gen/include/firewalld/dbus-proxies.h"
	insinto "${client_test_includes}/firewalld"
	doins "${OUT}/gen/include/firewalld/dbus-mocks.h"

	# Generate and install pkg-config for client libraries.
	insinto "/usr/$(get_libdir)/pkgconfig"
	./generate_pc_file.sh "${OUT}" libfirewalld-client "${client_includes}"
	doins "${OUT}/libfirewalld-client.pc"
	./generate_pc_file.sh "${OUT}" libfirewalld-client-test "${client_test_includes}"
	doins "${OUT}/libfirewalld-client-test.pc"
}

platform_pkg_test() {
	local tests=(
		firewalld_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
