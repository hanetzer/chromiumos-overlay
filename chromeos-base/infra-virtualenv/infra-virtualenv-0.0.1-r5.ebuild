# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="6437ed1ebf78de1ae3f785f632e849ec583210b9"
CROS_WORKON_TREE="d76c04bedd53708b1b8c1e9edbb051efdd575244"
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
	insinto "/opt/${PN}"
	doins -r *
	python_optimize "${D}/opt/${PN}"
}

src_test() {
	./bin/run_tests || die "Tests failed!"
}
