# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="2df829efebca0d12aab87fb5a4f9379d1fba0eb9"
CROS_WORKON_TREE="c6b510e7e57c86ea7ab5808d6d1e848585d74fa0"
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
	chromeos-base/libbrillo
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
	# Install DBus client library.
	platform_install_dbus_client_lib
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
