# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="88b9f7c31ed55b662ea4e9f55022b64b5dd47711"
CROS_WORKON_TREE="5684f4fff68207290a47f4120de35e0f942a6b58"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="power autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest +shill"

RDEPEND="
	shill? ( chromeos-base/shill-test-scripts )
	!<chromeos-base/autotest-tests-0.0.3
"
DEPEND="${RDEPEND}"

# cros/power_suspend depends on shill-test-scripts.
IUSE_TESTS="
	+tests_hardware_Backlight
	+tests_platform_CheckPowerdProcesses
	+tests_power_ARMSettings
	+tests_power_Backlight
	+tests_power_BacklightControl
	+tests_power_BacklightSuspend
	+tests_power_BatteryCharge
	+tests_power_CameraSuspend
	+tests_power_CheckAC
	+tests_power_CheckAfterSuspend
	+tests_power_CPUFreq
	+tests_power_CPUIdle
	+tests_power_Draw
	+tests_power_HotCPUSuspend
	+tests_power_KernelSuspend
	+tests_power_MemorySuspend
	+tests_power_NoConsoleSuspend
	+tests_power_ProbeDriver
	shill? ( +tests_power_Resume )
	+tests_power_Standby
	+tests_power_StatsCPUFreq
	+tests_power_StatsCPUIdle
	+tests_power_StatsUSB
	+tests_power_Status
	shill? ( +tests_power_SuspendStress )
	+tests_power_WakeupRTC
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
