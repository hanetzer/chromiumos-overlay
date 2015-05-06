# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="f540c5e89f5635614a7b5292950b6ec276519914"
CROS_WORKON_TREE="33f5a7b1e80eec1823fff49d4cbfa939102fb731"
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
