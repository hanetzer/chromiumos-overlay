# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="4aa146bfb5eaba06674137ca8df97c230eb84e8e"
CROS_WORKON_TREE="fa7022214a3ddf4223e6ade91728d00d8cdf1f08"

EAPI=2
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
