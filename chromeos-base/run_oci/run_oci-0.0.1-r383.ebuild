# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="2e7c4ea067186690aeeabf23756d360f1b18aa02"
CROS_WORKON_TREE="e0e0e0328546239d3a8574297f8f16f65dee1437"
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
		run_oci_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		# platform_test takes care of setting up your test environment
		platform_test "run" "${OUT}/${test_bin}"
	done
}
