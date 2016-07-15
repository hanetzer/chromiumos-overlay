# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="dd0ec8124bfdef9b499d80c89c7930ccc31aa5a9"
CROS_WORKON_TREE="39184d08365ec14faad3f53e5f950e9455e4ff59"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="login_OwnershipApi autotest"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+xset +tpmtools"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="${RDEPEND}
	chromeos-base/chromeos-chrome
	chromeos-base/protofiles
	chromeos-base/telemetry
	dev-libs/protobuf-python
	dev-python/pygobject
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	# Uses chrome test dependency.
	+tests_login_CryptohomeOwnerQuery
	+tests_login_GuestAndActualSession
	+tests_login_MultipleSessions
	+tests_login_MultiUserPolicy
	+tests_login_OwnershipApi
	+tests_login_OwnershipNotRetaken
	+tests_login_OwnershipRetaken
	+tests_login_OwnershipTaken
	+tests_login_RemoteOwnership
	+tests_login_UserPolicyKeys

	# Tests that depend on telemetry.
	+tests_login_OwnershipTakenTelemetry
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_prepare() {
	# Telemetry tests require the path to telemetry source to exist in order to
	# build.  Copy the telemetry source to a temporary directory that is writable,
	# so that file removals in Telemetry source can be performed properly.
	export TMP_DIR="$(mktemp -d)"
	cp -r "${SYSROOT}/usr/local/telemetry" "${TMP_DIR}"
	export PYTHONPATH="${TMP_DIR}/telemetry/src/third_party/catapult/telemetry"
	autotest_src_prepare
}
