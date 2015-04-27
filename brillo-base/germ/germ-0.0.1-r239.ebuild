# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="d9cbf1eba3d31fa24cb60535e2b956c14561d506"
CROS_WORKON_TREE="37b65cda30f5eef86b9b861af7ccd99b1efc7241"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="germ"

inherit cros-workon platform

DESCRIPTION="System service for sandboxing"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	brillo-base/libprotobinder
	brillo-base/libpsyche
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
"

DEPEND="${RDEPEND}
	brillo-base/soma
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	dobin "${OUT}/germ"
	dobin "${OUT}/germd"

	insinto /usr/include/"${PN}"
	doins constants.h

	# Install proto files.
	insinto /usr/share/proto
	doins idl/*.proto

	# Install Upstart files.
	insinto /etc/init
	doins init/germd.conf
	doins init/germ_template.conf
}

platform_pkg_test() {
	local tests=( germ_unittest )

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
