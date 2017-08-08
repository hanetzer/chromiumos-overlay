# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("4690f150a12c21fee0e92fb79a93a4802dd9711f" "64fc5a23a1ae487409cc585b3fbf261c553acb4e")
CROS_WORKON_TREE=("7847ef6af705054f446c2c8e2fb6618979d780eb" "b18efe1d20909f53842af15d2fb20a479a91b3d9")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/firewalld")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/firewalld")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/firewalld")

PLATFORM_SUBDIR="firewalld"

inherit cros-workon platform user

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
"

pkg_preinst() {
	# Create user and group for firewalld.
	enewuser "firewall"
	enewgroup "firewall"
}

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
