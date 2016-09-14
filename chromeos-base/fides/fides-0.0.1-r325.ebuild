# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="1b8d931117c99e31691654e5fcb3d75096daa29f"
CROS_WORKON_TREE="7b4724f55f7bed85bd495472e19747167f997116"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="fides"

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
		fides_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
