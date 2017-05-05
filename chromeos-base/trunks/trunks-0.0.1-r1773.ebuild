# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("7efef8ba6d8ef0edac8f71fec28db258a6d6b157" "f51c62531c31356fb9ea446d7b03a3cca4e447de")
CROS_WORKON_TREE=("eb25dfadef490ab2fdd3259b6eee7583ce34bd09" "c503755d771870c67c2e94ee2a0e71cb035dce36")
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
IUSE="cr50_onboard ftdi_tpm tpm2_simulator"

COMMON_DEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	chromeos-base/power_manager-client
	ftdi_tpm? ( dev-embedded/libftdi )
	tpm2_simulator? ( chromeos-base/tpm2 )
	"

RDEPEND="
	${COMMON_DEPEND}
	cr50_onboard? ( chromeos-base/chromeos-cr50 )
	"

DEPEND="
	${COMMON_DEPEND}
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
	elif use cr50_onboard; then
		newins trunksd.conf.cr50 trunksd.conf
	else
		doins trunksd.conf
	fi

	dosbin "${OUT}"/trunks_client
	dosbin "${OUT}"/trunks_send
	dosbin tpm_version
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
