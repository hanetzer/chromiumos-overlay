# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="79bb42c9087b2a220bcba9b48e6dbc3438954613"
CROS_WORKON_TREE="7cb449553a4db9cf13cc2193191f1fec1a188fe8"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="peerd autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

# Note that this RDEPEND doesn't actually pull in these packages, because
# autotest-tests-* aren't actually emerged into the image as of 2014.
# However, these tests do depend on dpkt, so I thought it would be good to
# document this.
RDEPEND="
	dev-python/dpkt
"

DEPEND="
	${RDEPEND}
"

IUSE_TESTS="
	+tests_peerd_AdvertiseServices
	+tests_peerd_DiscoverServices
	+tests_peerd_HandlesNameConflicts
"

IUSE="${IUSE} ${IUSE_TESTS}"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"
