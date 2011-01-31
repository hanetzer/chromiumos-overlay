# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="cd62d35e4c7d823a1b884f4ec0dcbd5ffe04a6d9"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest Factory tests"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

IUSE="+xset hardened"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

# Factory tests require locally installed deps, which are called out in
# autotest-factory-deps.
RDEPEND="
  chromeos-base/autotest-deps-iotools
  chromeos-base/autotest-deps-libaio
  chromeos-base/autotest-deps-glbench
  chromeos-base/autotest-private-board
  chromeos-base/flimflam
  xset? ( x11-apps/xset )
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_dummy_Fail
	+tests_dummy_Pass
	+tests_factory_Audio
	+tests_factory_Camera
	+tests_factory_DeveloperRecovery
	+tests_factory_Display
	+tests_factory_Dummy
	+tests_factory_EnableWriteProtect
	+tests_factory_ExtDisplay
	+tests_factory_ExternalStorage
	+tests_factory_Fail
	+tests_factory_Keyboard
	+tests_factory_Leds
	+tests_factory_LightSensor
	+tests_factory_PreFinalCheck
	+tests_factory_RebootStub
	+tests_factory_Review
	+tests_factory_ScriptWrapper
	+tests_factory_ShowTestResults
	+tests_factory_Touchpad
	+tests_factory_UploadLogs
	+tests_factory_LogVpd
	+tests_factory_Verify
	+tests_factory_Wipe
	+tests_factory_WriteGBB
	+tests_suite_Factory
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_PROJECT=autotest
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
