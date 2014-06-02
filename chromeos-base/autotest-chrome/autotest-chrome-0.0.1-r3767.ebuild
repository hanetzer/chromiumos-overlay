# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="766596e9057bc61df611b6d2674a6cf3a919b371"
CROS_WORKON_TREE="d9c5f279fbea85199566be726ef44f1a99e4a3c8"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest tests that require chrome_test, or telemetry deps"
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
	chromeos-base/chromeos-chrome
	chromeos-base/shill-test-scripts
	chromeos-base/telemetry
"

DEPEND="${RDEPEND}"

IUSE_TESTS=(
	# Inherits from enterprise_ui_test.
	+tests_desktopui_EnterprisePolicy

	# Uses chrome_test dependency.
	+tests_video_MediaUnittests
	+tests_video_VideoDecodeAccelerator
	+tests_video_VideoEncodeAccelerator
	+tests_video_VDAPerf

	# Tests that depend on telemetry.
	+tests_accessibility_Sanity
	+tests_audio_AudioCorruption
	+tests_bluetooth_RegressionClient
	+tests_desktopui_AudioFeedback
	+tests_desktopui_CameraApp
	+tests_desktopui_EchoExtension
	+tests_desktopui_FlashSanityCheck
	+tests_desktopui_MediaAudioFeedback
	+tests_desktopui_ScreenLocker
	+tests_desktopui_SimpleLogin
	+tests_desktopui_UrlFetchWithChromeDriver
	+tests_dummy_IdleSuspend
	+tests_graphics_Idle
	+tests_graphics_WebGLManyPlanetsDeep
	+tests_graphics_WebGLPerformance
	 tests_logging_AsanCrash
	+tests_logging_CrashServices
	+tests_login_ChromeProfileSanitary
	+tests_login_Cryptohome
	+tests_login_CryptohomeIncognito
	+tests_login_GaiaLogin
	+tests_login_LoginSuccess
	+tests_login_LogoutProcessCleanup
	+tests_network_ChromeCellularNetworkPresent
	+tests_network_ChromeCellularNetworkProperties
	+tests_network_ChromeCellularSmokeTest
	+tests_network_ChromeWifiConfigure
	+tests_network_ChromeWifiTDLS
	+tests_network_MobileSuspendResume
	+tests_platform_ChromeCgroups
	+tests_platform_SessionManagerBlockDevmodeSetting
	+tests_power_AudioDetector
	+tests_power_Consumption
	+tests_power_FlashVideoSuspend
	+tests_power_Idle
	+tests_power_IdleSuspend
	+tests_power_LoadTest
	+tests_power_UiResume
	+tests_power_VideoDetector
	+tests_power_VideoSuspend
	+tests_security_BundledExtensions
	+tests_security_NetworkListeners
	+tests_security_ProfilePermissions
	+tests_security_SandboxLinuxUnittests
	+tests_security_SandboxStatus
	+tests_telemetry_AFDOGenerateClient
	+tests_telemetry_LoginTest
	+tests_telemetry_UnitTests
	+tests_video_ChromeHWDecodeUsed
	+tests_video_ChromeRTCHWDecodeUsed
	+tests_video_ChromeRTCHWEncodeUsed
	+tests_video_ChromeVidResChangeHWDecode
	+tests_video_GlitchDetection
	+tests_video_MultiplePlayback
	+tests_video_VideoCorruption
	+tests_video_VideoDecodeMemoryUsage
	+tests_video_VideoReload
	+tests_video_VideoSanity
	+tests_video_VideoSeek
	+tests_video_VimeoVideo
	+tests_video_WebRtcPerf
	+tests_video_YouTubeFlash
	+tests_video_YouTubeHTML5
	+tests_video_YouTubeMseEme
	+tests_video_YouTubePage

	# Inherits from cros_ui_test. TODO(achuith): Delete or migrate these.
        tests_desktopui_TouchScreen
	# TODO(ihf): Move TearTest to autotest-tests and unify WebGL* with
	# Chromium waterfall once we have hardware there.
	tests_graphics_TearTest
	tests_realtimecomm_GTalkAudioPlayground
	tests_realtimecomm_GTalkPlayground
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
	# build. Copy the telemetry source to a temporary directory that is writable,
	# so that file removals in Telemetry source can be performed properly.
	export TMP_DIR="$(mktemp -d)"
	cp -r "${SYSROOT}/usr/local/telemetry" "${TMP_DIR}"
	export PYTHONPATH="${TMP_DIR}/telemetry/src/tools/telemetry"
	autotest_src_prepare
}

src_configure() {
	cros-workon_src_configure
}


