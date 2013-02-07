# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="a153ece56730c01d1349c8685ae42d2c0ad49a6d"
CROS_WORKON_TREE="72f387159e25237c5f153b8a7f3cebaf4c3b372d"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

CONFLICT_LIST="chromeos-base/autotest-tests-0.0.1-r596"

inherit toolchain-funcs flag-o-matic cros-workon autotest conflict

DESCRIPTION="ltp autotest"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

IUSE="hardened"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="${RDEPEND}
	chromeos-base/protofiles
	dev-libs/protobuf
	dev-python/pygobject
	!<chromeos-base/autotest-tests-0.0.1-r1723
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_ltp
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
