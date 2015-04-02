# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="399685c148390f439f959440f086d8eee4867634"
CROS_WORKON_TREE="9807671e2b80d7aa2226af6a7e72eeba8bcc0ff5"
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
