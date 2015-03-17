# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="262bdd3cd49c3ab7e32f7d47f1cf2e3a163d57ad"
CROS_WORKON_TREE="56b8863c5fe4e2e9b9b616e720851dae7c4d30ae"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="trunks"

inherit cros-workon platform user

DESCRIPTION="Trunks service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/libchromeos
	chromeos-base/system_api
	"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

src_install() {
	insinto /etc/dbus-1/system.d
	doins org.chromium.Trunks.conf

	insinto /etc/init
	doins trunksd.conf

	dosbin "${OUT}"/trunks_client
	dosbin "${OUT}"/trunksd
	dolib.so "${OUT}"/lib/libtrunks.so

	insinto /usr/share/policy
	newins trunksd-seccomp-${ARCH}.policy trunksd-seccomp.policy
}

platform_pkg_test() {
	"${S}/generator/generator_test.py" || die

	local tests=(
		trunks_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

pkg_preinst() {
	enewuser trunks
	enewgroup trunks
}
