# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5f4922c627d9eb895f6fcf35e1e19b090a5894a8"
CROS_WORKON_TREE="8c5fd781c24881fdf7d3479bde719fee69df0ec2"
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
