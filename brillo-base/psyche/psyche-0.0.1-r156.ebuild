# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="32a8d1c0ae6c470bdc1d08f77ab27ae4e64fa9bf"
CROS_WORKON_TREE="dc15760bf692721ce3d1eba8852d761f9c7eab2f"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="psyche"

inherit cros-workon platform

DESCRIPTION="Daemon for service registration and lookup"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	brillo-base/libprotobinder
	chromeos-base/libchrome
	chromeos-base/libchromeos
	dev-libs/protobuf
"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )"

src_compile() {
	platform compile psyched
	if use test; then
		platform compile psyched_test
	fi
}

src_install() {
	dosbin "${OUT}"/psyched

	insinto /etc/init
	doins psyched/psyched.conf
}

platform_pkg_test() {
	local tests=(
		psyched_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test run "${OUT}/${test_bin}"
	done
}
