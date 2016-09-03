# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("b30d37a85a504d7846f6d72a8cfbe0aef39b4aa8" "8560fb0566607e350ad8e9bd851ce04a5602b098")
CROS_WORKON_TREE=("3f4616459b672f8fa31e109af1c9c7273aba6092" "1b830cf7709a6aa85ea874c0fd55817f6a146bd0")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/tpm")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/tpm")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/tpm")
CROS_WORKON_USE_VCSID=1

PLATFORM_SUBDIR="trunks"

inherit cros-workon platform user

DESCRIPTION="Trunks service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="ftdi_tpm test tpm2_simulator"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	ftdi_tpm? ( dev-embedded/libftdi )
	tpm2_simulator? ( chromeos-base/tpm2 )
	"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/tpm/trunks"
}

src_install() {
	insinto /etc/dbus-1/system.d
	doins org.chromium.Trunks.conf

	insinto /etc/init
	if use tpm2_simulator; then
		newins trunksd.conf.tpm2_simulator trunksd.conf
	else
		doins trunksd.conf
	fi

	dosbin "${OUT}"/trunks_client
	dosbin "${OUT}"/trunksd
	dolib.so "${OUT}"/lib/libtrunks.so
	dolib.a "${OUT}"/libtrunks_test.a

	insinto /usr/share/policy
	newins trunksd-seccomp-${ARCH}.policy trunksd-seccomp.policy

	insinto /usr/include/trunks
	doins *.h
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
