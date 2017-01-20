# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="061588e616785df2a364be73a8fb513c908356fc"
CROS_WORKON_TREE="601f64cd9d5d1d3c4c3c3bf6aee8a7ec043ef2cc"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
PLATFORM_SUBDIR="container_utils"

inherit cros-workon platform user

DESCRIPTION="Helper utilities for generic containers"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libcontainer
	chromeos-base/permission_broker
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

pkg_preinst() {
	enewuser "user-containers"
	enewgroup "user-containers"
}
