# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="bf2e21f65ba1e665554f7cb917bb06fdef238ad2"
CROS_WORKON_TREE="e2eb2e5afb174467d87fce73a147244ad1f6b062"

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
