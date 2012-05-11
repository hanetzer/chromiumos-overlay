# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="7f280c5e9f4a185fad99240aaec9337276049313"
CROS_WORKON_TREE="c4393fb5e5e09f5bc4cc3debb03d3a3f009868a8"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest tests that require chrome_test or pyauto deps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="
	>chromeos-base/chromeos-chrome-19.0.1044.0_rc-r1
	!<=chromeos-base/chromeos-chrome-19.0.1044.0_rc-r1
	>chromeos-base/autotest-tests-0.0.1-r1528
	chromeos-base/flimflam-test
	tests_audiovideo_PlaybackRecordSemiAuto? ( media-sound/alsa-utils )
"

DEPEND="${RDEPEND}"

IUSE_TESTS=(
	# Inherits from chrome_test or pyauto_test.
	+tests_desktopui_BrowserTest
	+tests_desktopui_OMXTest
	+tests_desktopui_PyAutoFunctionalTests
	+tests_desktopui_PyAutoInstall
	+tests_desktopui_PyAutoPerfTests
	+tests_desktopui_SyncIntegrationTests

	# Inherits from enterprise_ui_test.
	+tests_desktopui_EnterprisePolicy

	# Inherits from cros_ui_test.
	+tests_audiovideo_PlaybackRecordSemiAuto
	+tests_desktopui_AudioFeedback
	+tests_desktopui_ChromeSemiAuto
	+tests_desktopui_FlashSanityCheck
	+tests_desktopui_IBusTest
	+tests_desktopui_ImeTest
	+tests_desktopui_MediaAudioFeedback
	+tests_desktopui_ScreenLocker
	+tests_desktopui_SunSpiderBench
	tests_desktopui_TouchScreen
	+tests_desktopui_UrlFetch
	+tests_desktopui_V8Bench
	+tests_graphics_GLAPICheck
	+tests_graphics_GpuReset
	+tests_graphics_Piglit
	+tests_graphics_SanAngeles
	+tests_graphics_TearTest
	+tests_graphics_WebGLConformance
	+tests_graphics_WebGLPerformance
	+tests_graphics_WindowManagerGraphicsCapture
	+tests_hardware_BluetoothSemiAuto
	+tests_hardware_ExternalDrives
	+tests_hardware_USB20
	+tests_hardware_UsbPlugIn
	+tests_logging_UncleanShutdown
	+tests_logging_UncleanShutdownServer
	+tests_login_BadAuthentication
	+tests_login_ChromeProfileSanitary
	+tests_login_CryptohomeIncognitoMounted
	+tests_login_CryptohomeIncognitoUnmounted
	+tests_login_CryptohomeMounted
	+tests_login_CryptohomeUnmounted
	+tests_login_LoginSuccess
	+tests_login_LogoutProcessCleanup
	+tests_login_RemoteLogin
	+tests_network_3GSuspendResume
	+tests_platform_Pkcs11InitOnLogin
	+tests_platform_ProcessPrivileges
	+tests_power_Idle
	+tests_power_IdleServer
	+tests_power_LoadTest
	+tests_realtimecomm_GTalkAudioPlayground
	+tests_realtimecomm_GTalkPlayground
	+tests_security_NetworkListeners
	+tests_security_ProfilePermissions
	+tests_security_RendererSandbox
)

IUSE="${IUSE} ${IUSE_TESTS[*]}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
