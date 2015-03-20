# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="ae5c29bd1462cc59c81c49e74803242915039f35"
CROS_WORKON_TREE="2f5e73da021dd584b5a906731f0c4cdbd0bc42b2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="privetd"

inherit cros-workon platform user

DESCRIPTION="Privet protocol handler for Chrome OS Core"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/libchrome_crypto
	chromeos-base/libchromeos
	chromeos-base/webserver
"

RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/apmanager
	chromeos-base/peerd
"

DEPEND="
	${COMMON_DEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
"

pkg_preinst() {
	# Create user and group for privetd.
	enewuser "privetd"
	enewgroup "privetd"
	# Additional groups to put privetd into.
	enewgroup "apmanager"
	enewgroup "buffet"
	enewgroup "peerd"
}

src_install() {
	dobin "${OUT}/privetd"
	# Install init scripts.
	insinto /etc/init
	doins init/privetd.conf
	# Install DBus configuration files.
	insinto /etc/dbus-1/system.d
	doins dbus_bindings/org.chromium.privetd.conf
}

platform_pkg_test() {
	local tests=(
		privetd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
