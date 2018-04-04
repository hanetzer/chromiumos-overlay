# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="bca1fd053debef0c43ec2b2955fd62a33190905f"
CROS_WORKON_TREE="0b86f6647925264727d9f4f80268cc94f5e3fff4"
CROS_WORKON_PROJECT="chromiumos/chromite"
CROS_WORKON_LOCALNAME="../../chromite"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-constants cros-workon python

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
	rm -rf lib/datafiles/
	rm -rf third_party/pyelftools/test
	rm -rf mobmonitor
}

src_test() {
	# Run the chromite unit tests, resetting the environment to the standard
	# one using a sudo invocation. Currently the tests assume they run from a
	# repo checkout, so they need to be run from the real source dir.
	# TODO(davidjames): Fix that, and run the tests from ${S} instead.
	cd "${CHROMITE_DIR}/cbuildbot" && sudo -u "${PORTAGE_USERNAME}" \
		PATH="${CROS_WORKON_SRCROOT}/../depot_tools:${PATH}" ./run_tests || die
}
