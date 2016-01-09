# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="917ca5a6c3b2613c85efa12b40bceaaf0889b57e"
CROS_WORKON_TREE="1a523aed84d0d4d2cd145492409daa68dedb5b71"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest

DESCRIPTION="Wimax autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.2
	chromeos-base/autotest-deps-cellular
	chromeos-base/shill-test-scripts
	dev-python/pygobject
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_network_WiMaxPresent
	+tests_network_WiMaxSmoke
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_configure() {
	cros-workon_src_configure
}
