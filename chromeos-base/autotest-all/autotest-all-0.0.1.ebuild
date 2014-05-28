# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-constants


DESCRIPTION="Meta ebuild for all packages providing tests"
HOMEPAGE="http://www.chromium.org"

LICENSE="GPL-2"
SLOT=0
KEYWORDS="*"
IUSE="+cellular -chromeless_tty -ecs wimax"

RDEPEND="
	chromeos-base/autotest-client
	chromeos-base/autotest-tests
	chromeos-base/autotest-server-tests
	chromeos-base/autotest-tests-ltp
	chromeos-base/autotest-factory-install
	chromeos-base/autotest-private-all
	cellular? (
		chromeos-base/autotest-tests-cellular
	)
	!chromeless_tty? (
		!ecs? (
			chromeos-base/autotest-tests-ownershipapi
			chromeos-base/autotest-tests-touchpad
			chromeos-base/autotest-chrome
		)
	)
	wimax? (
		chromeos-base/autotest-tests-wimax
	)
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
