# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="66f6592c5ee78ffe122111d3659f497a296ce1a0"
CROS_WORKON_TREE="ad76c8e9b6b6e3285141de2830e8e670ab2ad804"
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
	+tests_login_MultipleSessions
	+tests_login_GuestAndActualSession
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
	export PYTHONPATH="${TMP_DIR}/telemetry/src/tools/telemetry"
	autotest_src_prepare
}
