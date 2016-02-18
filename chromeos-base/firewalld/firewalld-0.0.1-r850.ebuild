# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("5d3b89ed6431d871b90719dc9336e227e29c6bf2" "835d2c2d6f151059c4d70adbfdac9aca7b3f98c5")
CROS_WORKON_TREE=("2d9529cd2fe6509893f8cdde1f9e5e687f3e3eb5" "abf1bd1bfe6e26da5a7b812c905104aae4c4345a")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/firewalld")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/firewalld")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/firewalld")

PLATFORM_SUBDIR="firewalld"

inherit cros-workon platform

DESCRIPTION="System service for handling firewall rules"
HOMEPAGE="http://www.chromium.org/"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
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
