# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("5ade4272fa8cc7d4a2aa2442c5e8572329a36473" "685fba094dc8bcc556ff23e4330811d96bd17599")
CROS_WORKON_TREE=("161e09a54e42370f807f48b5d4e95350ac0ee38a" "49f9103629b8559ee42dd5d4de7ba1962dfb77c8")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/apmanager")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/connectivity/apmanager")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/connectivity/apmanager")
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="apmanager"

inherit cros-workon platform user

DESCRIPTION="Access Point Manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
IUSE="test"
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	chromeos-base/permission_broker
	net-dns/dnsmasq
	net-wireless/hostapd
"

DEPEND="
	${RDEPEND}
	chromeos-base/permission_broker-client
	chromeos-base/shill
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/connectivity/apmanager"
}

src_install() {
	dobin "${OUT}"/apmanager
	# Install init scripts.
	insinto /etc/init
	doins init/apmanager.conf

	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.apmanager.conf

	# Install DBus client library.
	platform_install_dbus_client_lib

	# Install seccomp file.
	insinto /usr/share/policy
	newins init/apmanager-seccomp-${ARCH}.policy apmanager-seccomp.policy
}

pkg_preinst() {
	# Create user and group for apmanager.
	enewuser "apmanager"
	enewgroup "apmanager"
}

platform_pkg_test() {
	local tests=(
		apmanager_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
