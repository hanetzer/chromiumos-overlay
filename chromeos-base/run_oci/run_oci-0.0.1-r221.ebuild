# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="c1d7c166d4d88d57fbe9722a47bb18d84bc12ab6"
CROS_WORKON_TREE="9271dff20adb306b57700240776dbc93e5a293a3"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
PLATFORM_SUBDIR="run_oci"

inherit cros-workon libchrome platform

DESCRIPTION="Utility for running OCI-compatible containers"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libcontainer
	sys-libs/libcap
"
DEPEND="${RDEPEND}"

src_install() {
	cd "${OUT}"
	dobin run_oci
}

platform_pkg_test() {
	local tests=(
		container_config_parser_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		# platform_test takes care of setting up your test environment
		platform_test "run" "${OUT}/${test_bin}"
	done
}
