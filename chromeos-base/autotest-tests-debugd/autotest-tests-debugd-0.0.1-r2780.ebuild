# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="ce6b262b143e0dfdf5f6d877e6f1caceba07c64c"
CROS_WORKON_TREE="ac8d2d13dbe56e6734b677ed5627bcf76a469210"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="debugd autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
"

IUSE_TESTS="
	+tests_platform_TraceClockMonotonic
	+tests_platform_CheckDebugdProcesses
	+tests_platform_DebugDaemonGetModemStatus
	+tests_platform_DebugDaemonGetNetworkStatus
	+tests_platform_DebugDaemonGetPerfData
	+tests_platform_DebugDaemonGetRoutes
	+tests_platform_DebugDaemonPing
	+tests_platform_DebugDaemonTracePath
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
