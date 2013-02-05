# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="b0b0b839a78f8690b11db4ce3cccb38baf1dab4d"
CROS_WORKON_TREE="3ebdbd40614bee1d8b90fd15dcb7e8a66bc7d047"
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
	chromeos-base/flimflam-test
	chromeos-base/chromeos-chrome
	chromeos-base/protofiles
	dev-libs/protobuf
	dev-python/pygobject
	autox? ( chromeos-base/autox )
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_login_OwnershipApi
	+tests_login_OwnershipNotRetaken
	+tests_login_OwnershipRetaken
	+tests_login_OwnershipTaken
	+tests_login_RemoteOwnership
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
