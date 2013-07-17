# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="dca355d190ee9688b4d45a61cf0c49cb9d16bea2"
CROS_WORKON_TREE="7fd667e41ffdf338c4f18de3dd622840ebb61bc0"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

CONFLICT_LIST="chromeos-base/autotest-tests-0.0.1-r596"

inherit toolchain-funcs flag-o-matic cros-workon autotest conflict

DESCRIPTION="login_OwnershipApi autotest"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

IUSE="+autox +xset +tpmtools hardened"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="${RDEPEND}
	chromeos-base/shill-test-scripts
	chromeos-base/chromeos-chrome
	chromeos-base/protofiles
	dev-libs/protobuf
	dev-python/pygobject
	autox? ( chromeos-base/autox )
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_login_MultipleSessions
	+tests_login_GuestAndActualSession
	+tests_login_MultiUserPolicy
	+tests_login_OwnershipApi
	+tests_login_OwnershipNotRetaken
	+tests_login_OwnershipRetaken
	+tests_login_OwnershipTaken
	+tests_login_RemoteOwnership
	+tests_login_UserPolicyKeys
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
