# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="45a37599fa499a1db1e054d373d614d9aa407bf7"
CROS_WORKON_TREE="7262945c6ae23338437ecb55834d90e4933f173f"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="leaderd"

inherit cros-workon platform user

DESCRIPTION="Leadership election services for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
	chromeos-base/peerd
	chromeos-base/privetd
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

pkg_preinst() {
	# Create user and group for leaderd.
	enewuser "leaderd"
	enewgroup "leaderd"
}

src_install() {
	dobin "${OUT}/leaderd"
	# Install init scripts.
	insinto /etc/init
	doins init/leaderd.conf
	# Install DBus configuration files.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.leaderd.conf
}

platform_pkg_test() {
	local tests=(
		leaderd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
