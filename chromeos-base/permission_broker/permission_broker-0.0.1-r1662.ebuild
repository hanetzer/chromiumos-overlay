# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="044603c893d8a8a8d092ac2eb23a2a01a64dfdee"
CROS_WORKON_TREE="4ad3f9b8a596cb2749bda5d35d2caf02fdb780aa"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="${PN}"

inherit cros-workon platform udev user

DESCRIPTION="Permission Broker for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/firewalld
	chromeos-base/libbrillo
	dev-libs/glib
	sys-apps/dbus
	dev-libs/dbus-glib
	virtual/udev"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)"

src_install() {
	dobin "${OUT}"/permission_broker

	# Install upstart configuration
	insinto /etc/init
	doins permission_broker.conf

	# DBus configuration
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.PermissionBroker.conf

	# Udev rules for hidraw nodes
	udev_dorules "${FILESDIR}/99-hidraw.rules"
}

platform_pkg_test() {
	local tests=(
		permission_broker_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

pkg_preinst() {
	enewuser "devbroker"
	enewgroup "devbroker"
	enewgroup "devbroker-access"
}
