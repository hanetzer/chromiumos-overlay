# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="97ac6329e0ddf74d6be94a6f8e6960f2d30c0683"
CROS_WORKON_TREE="c4663dd43fd4c425e63013a755a2d8f75697fd20"
CROS_WORKON_PROJECT="chromiumos/chromite"
CROS_WORKON_LOCALNAME="../../chromite"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon python

DESCRIPTION="Wrapper for running chromite unit tests"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

src_install() {
	use cros_host && return
	insinto "$(python_get_sitedir)/chromite"
	doins -r "${S}"/*
	# TODO (crbug.com/346859) Convert to using distutils and a setup.py
	# to specify which files should be installed.
	cd "${D}/$(python_get_sitedir)/chromite"
	find '(' -name '*.pyc' -o -name '*unittest.py' ')' -delete
	rm -rf third_party/pyelftools/test
}

src_test() {
	# Run the chromite unit tests, resetting the environment to the standard
	# one using a sudo invocation.
	cd "${S}"/buildbot && sudo -u "${PORTAGE_USERNAME}" \
		PATH="${CROS_WORKON_SRCROOT}/../depot_tools:${PATH}" ./run_tests || die
}
