# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="de76ccfea97f52c3905ae26ac8244ef9f3cbfb8b"
CROS_WORKON_TREE="ec58c9c1f3faaa55f53f16234fcbe7c43ede66fc"
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
