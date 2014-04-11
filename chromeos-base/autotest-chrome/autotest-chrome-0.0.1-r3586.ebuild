# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="ce6a093a67f12cd6351a2f9c17b22ef54102a394"
CROS_WORKON_TREE="da4863f53eeffc152081bda45f9f700b6cdc0a42"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest tests that require chrome_test, pyauto, or telemetry deps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="
	!chromeos-base/autotest-telemetry
	chromeos-base/autotest-deps-graphics
	chromeos-base/autotest-deps-webgl-mpd
	chromeos-base/autotest-deps-webgl-perf
	chromeos-base/autotest-tests
	chromeos-base/chromeos-chrome
	chromeos-base/shill-test-scripts
	chromeos-base/telemetry
	tests_audio_PlaybackRecordSemiAuto? ( media-sound/alsa-utils )
"

DEPEND="${RDEPEND}"

IUSE_TESTS=(
	# Inherits from enterprise_ui_test.
	+tests_desktopui_EnterprisePolicy

	# Uses chrome_test dependency.
	+tests_video_VideoDecodeAccelerator
	+tests_video_VideoEncodeAccelerator
	+tests_video_VDAPerf

	# Tests that depend on telemetry.
	+tests_audio_AudioCorruption
	+tests_bluetooth_RegressionClient
	+tests_desktopui_AudioFeedback
	+tests_desktopui_EchoExtension
	+tests_desktopui_ScreenLocker
	+tests_login_ChromeProfileSanitary
	+tests_login_CryptohomeIncognito
	+tests_login_Cryptohome
	+tests_login_LoginSuccess
	+tests_login_LogoutProcessCleanup
	+tests_network_ChromeCellularNetworkPresent
	+tests_network_ChromeCellularNetworkProperties
	+tests_network_ChromeCellularSmokeTest
	+tests_network_ChromeWifiConfigure
	+tests_network_ChromeWifiTDLS
	+tests_security_BundledExtensionsTelemetry
	+tests_security_ProfilePermissionsTelemetry
	+tests_security_SandboxStatusTelemetry
	+tests_telemetry_LoginTest
	+tests_telemetry_UnitTests
	+tests_video_ChromeHWDecodeUsed
	+tests_video_MultiplePlayback
	+tests_video_VideoCorruption
	+tests_video_VideoDecodeMemoryUsage
	+tests_video_VideoSanity
	+tests_video_VideoSeek
	+tests_video_VimeoVideo
	+tests_video_WebRtcPerf
	+tests_video_YouTubePage
	+tests_video_YouTubeFlash
	+tests_video_YouTubeHTML5
	+tests_video_YouTubeMseEme

	# Inherits from cros_ui_test.
	+tests_desktopui_BrowserTest
	+tests_desktopui_CameraApp
	+tests_desktopui_DocViewing
	+tests_desktopui_PyAutoFunctionalTests
	+tests_desktopui_PyAutoInstall
	+tests_desktopui_PyAutoPerfTests
	+tests_desktopui_SyncIntegrationTests
	+tests_audio_PlaybackRecordSemiAuto
	+tests_desktopui_ChromeSemiAuto
	+tests_desktopui_FlashSanityCheck
	+tests_desktopui_IBusTest
	+tests_desktopui_ImeTest
	+tests_desktopui_LoadBigFile
	+tests_desktopui_MediaAudioFeedback
	+tests_desktopui_NaClSanity
	+tests_desktopui_SimpleLogin
	 tests_desktopui_TouchScreen
	+tests_desktopui_UrlFetch
	+tests_desktopui_UrlFetchWithChromeDriver
	+tests_dummy_IdleSuspend
	+tests_enterprise_DevicePolicy
	+tests_enterprise_InstallAttributes
	+tests_enterprise_Policies
	# TODO(ihf): Move TearTest to autotest-tests and unify WebGL* with
	# Chromium waterfall once we have hardware there.
	+tests_graphics_TearTest
	+tests_graphics_WebGLManyPlanetsDeep
	+tests_graphics_WebGLPerformance
	+tests_hardware_BluetoothSemiAuto
	+tests_hardware_ExternalDrives
	+tests_hardware_USB20
	+tests_hardware_UsbPlugIn
	 tests_logging_AsanCrash
	 tests_logging_AsanCrashTelemetry
	+tests_logging_UncleanShutdown
	+tests_network_MobileSuspendResume
	+tests_network_NavigateToUrl
	+tests_network_ONC
	+tests_platform_ChromeCgroups
	+tests_platform_Pkcs11InitOnLogin
	+tests_platform_Pkcs11Persistence
	+tests_platform_ProcessPrivileges
	+tests_power_AudioDetector
	+tests_power_Consumption
	+tests_power_FlashVideoSuspend
	+tests_power_Idle
	+tests_power_IdleSuspend
	+tests_power_LoadTest
	+tests_power_SuspendStress
	+tests_power_UiResume
	+tests_power_VideoDetector
	+tests_power_VideoSuspend
	+tests_realtimecomm_GTalkAudioPlayground
	+tests_realtimecomm_GTalkPlayground
	+tests_security_NetworkListeners
	+tests_security_ProfilePermissions
	+tests_security_RendererSandbox
	+tests_security_SandboxLinuxUnittests
	+tests_security_SandboxStatusBrowserTest
	+tests_telemetry_AFDOGenerateClient
)

IUSE="${IUSE} ${IUSE_TESTS[*]}"

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

src_configure() {
	cros-workon_src_configure
}


