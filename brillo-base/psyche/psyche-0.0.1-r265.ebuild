# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="1c5a57a8f4d760f1716e7579693eac791da59b5e"
CROS_WORKON_TREE="389156c68120832491a5747555f6b3dce620de7f"
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
	brillo-base/soma
	chromeos-base/libchromeos
	dev-libs/protobuf
"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )"

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
