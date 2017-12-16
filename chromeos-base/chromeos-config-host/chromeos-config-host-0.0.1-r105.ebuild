# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="d81814f4c11bfc64646b281c5e7b9688087b2ce1"
CROS_WORKON_TREE="7e6879c5c212951d5e85594d17103f1a2b894d45"
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
