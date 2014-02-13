# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="09fe01248d6b24e1d831413e16c2b97da14ae22a"
CROS_WORKON_TREE="5af018f103afd442bd9aa9cbd1a7a89ef25f62b8"
CROS_WORKON_PROJECT="chromiumos/chromite"
CROS_WORKON_LOCALNAME="../../chromite"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Wrapper for running chromite unit tests"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

src_test() {
	# Run the chromite unit tests, resetting the environment to the standard
	# one using a sudo invocation.
	cd "${S}"/buildbot && sudo -u "${PORTAGE_USERNAME}" \
		PATH="${CROS_WORKON_SRCROOT}/../depot_tools:${PATH}" ./run_tests || die
}
