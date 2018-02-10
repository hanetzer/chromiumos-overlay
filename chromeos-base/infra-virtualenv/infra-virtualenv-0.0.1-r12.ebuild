# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="500052dac368dbbef4cdc9b11e824b1f73a924e4"
CROS_WORKON_TREE="ba526349eb6be43ed675a4461fc717d982a9e554"
PYTHON_COMPAT=( python2_7 )
inherit cros-workon python-r1

CROS_WORKON_PROJECT="chromiumos/infra_virtualenv"
CROS_WORKON_LOCALNAME="../../infra_virtualenv"

DESCRIPTION="Python virtualenv for Chromium OS infrastructure"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/infra_virtualenv/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/virtualenv[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
	python_setup
}

src_install() {
	insinto "/opt/infra_virtualenv"
	doins -r *
	fperms -R 755 /opt/infra_virtualenv/bin
	python_optimize "${D}/opt/infra_virtualenv"
}

src_test() {
	./bin/run_tests || die "Tests failed!"
}
