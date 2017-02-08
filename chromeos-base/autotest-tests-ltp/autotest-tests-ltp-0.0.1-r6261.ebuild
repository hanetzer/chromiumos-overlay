# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="627a75ebc4cc2f755ccad17d1c9f92c91cc2e776"
CROS_WORKON_TREE="01d16df6f1d3c7d6b5544c976dff9d95cd8992eb"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="ltp autotest"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

RDEPEND="${RDEPEND}
	chromeos-base/autotest-deps-ltp
	chromeos-base/protofiles
	dev-libs/protobuf-python
	dev-python/pygobject
	!<chromeos-base/autotest-tests-0.0.1-r1723
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_kernel_LTP
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
