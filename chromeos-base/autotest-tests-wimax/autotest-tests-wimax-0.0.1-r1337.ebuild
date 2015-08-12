# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1a2edd4df71e7f42577797cf201f276a9cda888e"
CROS_WORKON_TREE="77206fd515d15a5d5d0f5e030e7ac822e5735906"
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
