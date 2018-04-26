# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="bd33427afb37ec05127792091ffc87bfefb48121"
CROS_WORKON_TREE="7a6622ac81d14b79801092a2e2a5575eccbbaa43"
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
