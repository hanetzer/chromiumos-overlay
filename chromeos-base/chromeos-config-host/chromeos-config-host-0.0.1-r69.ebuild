# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="6415a4c2d4909019cdc5e5c770630af3ac5fe58c"
CROS_WORKON_TREE="ad0e7bdf8234a88b44619f595b374a09c91f929a"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"

PYTHON_COMPAT=( python2_7 )

inherit cros-workon distutils-r1

DESCRIPTION="Chrome OS configuration host tools"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/chromeos-config"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	sys-apps/dtc[python]
	!<chromeos-base/chromeos-config-tools-0.0.2
"

DEPEND="
	${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_unpack() {
    cros-workon_src_unpack
    S+="/chromeos-config"
}

src_compile() {
	distutils-r1_src_compile
	einfo "Validating master configuration binding"
	python -m cros_config_host.validate_config README.md ||
		die "Validation failed"
}

src_test() {
	./chromeos-config-test-setup.sh
	./run_tests.sh || die "cros_config unit tests have errors"
}