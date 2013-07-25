# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d6812850f4e2c9cc07044ef9693f640e10512dca"
CROS_WORKON_TREE="2f7db0669ba73d0d46a758def61d7dca4b803553"
CROS_WORKON_PROJECT="chromiumos/chromite"
CROS_WORKON_LOCALNAME="../../chromite"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Wrapper for running chromite unit tests"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

src_test() {
	# Run the chromite unit tests, resetting the environment to the standard
	# one using a sudo invocation.
	cd "${S}"/buildbot && sudo -u "${PORTAGE_USERNAME}" \
		PATH="${CROS_WORKON_SRCROOT}/../depot_tools:${PATH}" ./run_tests || die
}
