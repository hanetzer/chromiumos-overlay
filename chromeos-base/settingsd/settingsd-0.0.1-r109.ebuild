# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="5f0429aefa4d69a637790fa0f6ba00292f1be2fa"
CROS_WORKON_TREE="8af285a55772e085789b894835fd7a95c8e0a6f4"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="settingsd"

inherit cros-workon libchrome platform

DESCRIPTION="Device Configuration Management Services"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

DEPEND="
	test? ( dev-cpp/gtest )
"

platform_pkg_test() {
	local tests=(
		settingsd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
