# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-constants

DESCRIPTION="Autotest components used by the factory."
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

DEPEND="
	chromeos-base/autotest-client
	chromeos-base/autotest-tests
"

S=${WORKDIR}

IUSE_TESTS="
	+tests_hardware_SAT
"

src_install() {
	local test_list=(
		hardware_SAT
	)
	local package_path="${SYSROOT}/${AUTOTEST_BASE}/packages"
	local each_test
	for each_test in "${test_list[@]}"; do
		dodir /usr/local/autotest/site_tests/${each_test}
		tar xvf \
			"${package_path}/test-${each_test}.tar.bz2" \
			-C "${D}"/usr/local/autotest/site_tests/${each_test} || die
	done
}
