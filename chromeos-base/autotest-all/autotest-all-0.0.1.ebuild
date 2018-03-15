# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cros-constants

DESCRIPTION="Meta ebuild for all packages providing tests"
HOMEPAGE="http://www.chromium.org"

LICENSE="GPL-2"
SLOT=0
KEYWORDS="*"
IUSE="cheets -chromeless_tests +bluetooth buffet +cellular +cras +cros_disks +cros_p2p +debugd -chromeless_tty kvm_host peerd +power_management +shill +tpm tpm2"

RDEPEND="
	chromeos-base/autotest-client
	chromeos-base/autotest-private-all
	chromeos-base/autotest-server-tests
	chromeos-base/autotest-server-tests-tast
	chromeos-base/autotest-tests
	chromeos-base/autotest-tests-ltp
	chromeos-base/autotest-tests-security
	chromeos-base/autotest-tests-toolchain
	chromeos-base/ci-results-archiver
	bluetooth? ( chromeos-base/autotest-server-tests-bluetooth )
	buffet? ( chromeos-base/autotest-tests-cloud-services )
	cellular? ( chromeos-base/autotest-tests-cellular )
	cheets? ( chromeos-base/autotest-tests-arc-public )
	!chromeless_tty? (
		chromeos-base/autotest-tests-cryptohome
		!chromeless_tests? (
			chromeos-base/autotest-chrome
			chromeos-base/autotest-server-tests-telemetry
			chromeos-base/autotest-tests-graphics
			chromeos-base/autotest-tests-ownershipapi
			chromeos-base/autotest-tests-touchpad
		)
	)
	cras? ( chromeos-base/autotest-tests-audio )
	cros_disks? ( chromeos-base/autotest-tests-cros-disks )
	cros_p2p? ( chromeos-base/autotest-tests-p2p )
	debugd? ( chromeos-base/autotest-tests-debugd )
	kvm_host? ( chromeos-base/autotest-tests-vm-host )
	peerd? ( chromeos-base/autotest-tests-peerd )
	power_management? ( chromeos-base/autotest-tests-power )
	shill? (
		chromeos-base/autotest-server-tests-shill
		chromeos-base/autotest-tests-shill
	)
	tpm2? ( chromeos-base/autotest-tests-tpm )
	tpm? ( chromeos-base/autotest-tests-tpm )
"

DEPEND="${RDEPEND}"

SUITE_DEPENDENCIES_FILE="dependency_info"
SUITE_TO_CONTROL_MAP="suite_to_control_file_map"

src_unpack() {
	elog "Unpacking..."
	mkdir -p "${S}"
	touch "${S}/${SUITE_DEPENDENCIES_FILE}"
	touch "${S}/${SUITE_TO_CONTROL_MAP}"
}

src_install() {
	# So that this package properly owns the file
	insinto ${AUTOTEST_BASE}/test_suites
	doins "${SUITE_DEPENDENCIES_FILE}"
	doins "${SUITE_TO_CONTROL_MAP}"
}

# Pre-processes control files and installs DEPENDENCIES info.
pkg_postinst() {
	local root_autotest_dir="${ROOT}${AUTOTEST_BASE}"
	python -B "${root_autotest_dir}/site_utils/suite_preprocessor.py" \
		-a "${root_autotest_dir}" \
		-o "${root_autotest_dir}/test_suites/${SUITE_DEPENDENCIES_FILE}"
	python -B "${root_autotest_dir}/site_utils/control_file_preprocessor.py" \
		-a "${root_autotest_dir}" \
		-o "${root_autotest_dir}/test_suites/${SUITE_TO_CONTROL_MAP}"
}
