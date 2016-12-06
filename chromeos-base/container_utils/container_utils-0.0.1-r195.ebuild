# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4e62cc191d197258caaa62ebbac4acac3f2601fa"
CROS_WORKON_TREE="359769010b5f8c7044f4e0639d36d7e3ff6dad4f"
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
	chromeos-base/permission_broker
	dev-libs/dbus-c++
"
DEPEND="${RDEPEND}"

src_install() {
	cd "${OUT}"
	dobin broker_service
	dobin run_oci
	cd "${S}"
	insinto /etc/init
	doins broker-service.conf
	doins broker-service-pre-upstart-socket-bridge.conf
	doins broker-service-post-upstart-socket-bridge.conf
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
