# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("ef841f2c1f06ce2402b23b91179d51001f9b0397" "f4dd2faedc467ebe4d37bb21e54dc1afcc4c3bda")
CROS_WORKON_TREE=("25dedd3358eb5a82f0622df6f1dfb273e5bbb87a" "977f6c1f728023aa1488a8276374b12e0bf7d8ff")
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
IUSE="cr50_onboard ftdi_tpm test tpm2_simulator"

COMMON_DEPEND="
	chromeos-base/minijail
	chromeos-base/libbrillo
	chromeos-base/power_manager-client
	ftdi_tpm? ( dev-embedded/libftdi )
	tpm2_simulator? ( chromeos-base/tpm2 )
	"

RDEPEND="
	${COMMON_DEPEND}
	cr50_onboard? ( chromeos-base/chromeos-cr50 )
	"

DEPEND="${COMMON_DEPEND}"

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
	use test && dolib.a "${OUT}"/libtrunks_test.a

	insinto /usr/share/policy
	newins trunksd-seccomp-${ARCH}.policy trunksd-seccomp.policy

	insinto /usr/include/trunks
	doins *.h

	"${PLATFORM_TOOLDIR}/generate_pc_file.sh" \
		"${OUT}/lib" libtrunks /usr/include/trunks
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/lib/libtrunks.pc
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