# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="c2815926173253eb43c13d02e79c9e514dac4926"
CROS_WORKON_TREE="22f3898b8198c18e859a6931d7e2c3e69c763c87"
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
