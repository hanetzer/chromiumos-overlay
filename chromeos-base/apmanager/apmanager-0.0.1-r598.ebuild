# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="045bdab3b95c34ab0ac0e5066ca78223eba4c675"
CROS_WORKON_TREE="ae74226a5968ec25a5af09a22a231cd8e60079b7"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

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
	chromeos-base/libchromeos
	chromeos-base/permission_broker
	net-dns/dnsmasq
	net-wireless/hostapd
"

DEPEND="
	${RDEPEND}
	chromeos-base/shill
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
"

src_install() {
	dobin "${OUT}"/apmanager
	# Install init scripts.
	insinto /etc/init
	doins init/apmanager.conf
	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.apmanager.conf
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
