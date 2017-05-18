# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5734df660a52c6c33a03474b61288cc2d09eb6a9"
CROS_WORKON_TREE="2cc3cb17b2cbf526acf26927073586a87c351d64"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest tests that require chrome_binary_test, or telemetry deps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="
	${IUSE}
	+autotest
	+cellular
	+shill
	+tpm
	tpm2
	vaapi
"

RDEPEND="
	!chromeos-base/autotest-telemetry
	!<chromeos-base/autotest-tests-0.0.4
	chromeos-base/autotest-deps-graphics
	chromeos-base/autotest-deps-webgl-mpd
	chromeos-base/autotest-deps-webgl-perf
	chromeos-base/chromeos-chrome
	shill? ( chromeos-base/shill-test-scripts )
	chromeos-base/telemetry
	vaapi? ( x11-libs/libva )
"

DEPEND="${RDEPEND}"

IUSE_TESTS=(
	# Uses chrome_binary_test dependency.
	+tests_video_JpegDecodeAccelerator
	+tests_video_VideoDecodeAccelerator
	+tests_video_VideoEncodeAccelerator
	+tests_video_VDAPerf
	+tests_video_VDASanity
	+tests_video_VEAPerf

	# Tests that depend on telemetry.
	+tests_accessibility_Sanity
	+tests_accessibility_ChromeVoxSound
	+tests_audio_ActiveStreamStress
	+tests_audio_AudioCorruption
	+tests_audio_CrasSanity
	+tests_audio_PlaybackPower
	+tests_audio_SeekAudioFeedback
	+tests_bluetooth_AdapterSanity
	+tests_bluetooth_IDCheck
	+tests_bluetooth_RegressionClient
	+tests_desktopui_AudioFeedback
	tests_desktopui_CameraApp
	tests_desktopui_ConnectivityDiagnostics
	+tests_desktopui_ExitOnSupervisedUserCrash
	+tests_desktopui_FlashSanityCheck
	+tests_desktopui_MashLogin
	+tests_desktopui_MediaAudioFeedback
	+tests_desktopui_MusLogin
	+tests_desktopui_ScreenLocker
	+tests_desktopui_SimpleLogin
	+tests_desktopui_UrlFetchWithChromeDriver
	+tests_display_ClientChameleonConnection
	+tests_dummy_IdleSuspend
	+tests_enterprise_CFM_USBPeripheralDetect
	+tests_enterprise_CFM_VolumeChangeClient
	+tests_enterprise_KioskEnrollment
	+tests_enterprise_PowerManagement
	+tests_enterprise_RemoraRequisition
	+tests_graphics_Idle
	+tests_graphics_WebGLAquarium
	+tests_graphics_WebGLManyPlanetsDeep
	+tests_graphics_WebGLPerformance
	+tests_graphics_Stress
	+tests_graphics_VTSwitch
	 tests_logging_AsanCrash
	+tests_logging_CrashServices
	+tests_logging_FeedbackReport
	+tests_login_ChromeProfileSanitary
	+tests_login_Cryptohome
	+tests_login_CryptohomeIncognito
	+tests_login_GaiaLogin
	+tests_login_LoginSuccess
	+tests_login_LogoutProcessCleanup
	+tests_login_OobeLocalization
	+tests_longevity_Tracker
	+tests_network_CastTDLS
	+tests_network_ChromeWifiConfigure
	+tests_network_ChromeWifiTDLS
	+tests_performance_InboxInputLatency
	+tests_platform_ChromeCgroups
	+tests_platform_InputBrightness
	+tests_platform_InputBrowserNav
	+tests_platform_InputNewTab
	+tests_platform_InputScreenshot
	+tests_platform_InputVolume
	+tests_platform_OSLimits
	+tests_platform_SessionManagerBlockDevmodeSetting
	+tests_policy_ChromeOsLockOnIdleSuspend
	+tests_policy_CookiesAllowedForUrls
	+tests_policy_CookiesBlockedForUrls
	+tests_policy_CookiesSessionOnlyForUrls
	+tests_policy_DisableScreenshots
	+tests_policy_EditBookmarksEnabled
	+tests_policy_ForceGoogleSafeSearch
	+tests_policy_ForceYouTubeSafetyMode
	+tests_policy_ImagesAllowedForUrls
	+tests_policy_ImagesBlockedForUrls
	+tests_policy_JavaScriptAllowedForUrls
	+tests_policy_JavaScriptBlockedForUrls
	+tests_policy_ManagedBookmarks
	+tests_policy_NotificationsAllowedForUrls
	+tests_policy_NotificationsBlockedForUrls
	+tests_policy_PluginsAllowedForUrls
	+tests_policy_PluginsBlockedForUrls
	+tests_policy_PopupsAllowedForUrls
	+tests_policy_PopupsBlockedForUrls
	+tests_policy_PowerManagementIdleSettings
	+tests_policy_ProxySettings
	+tests_policy_RestoreOnStartupURLs
	+tests_policy_URLBlacklist
	+tests_policy_URLWhitelist
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
	+tests_touch_MouseScroll
	+tests_touch_ScrollDirection
	+tests_touch_TapSettings
	+tests_touch_TabSwitch
	+tests_touch_TouchscreenScroll
	+tests_touch_TouchscreenTaps
	+tests_touch_TouchscreenZoom
	+tests_touch_StylusTaps
	+tests_video_ChromeHWDecodeUsed
	+tests_video_ChromeRTCHWDecodeUsed
	+tests_video_ChromeRTCHWEncodeUsed
	+tests_video_ChromeVidResChangeHWDecode
	+tests_video_GlitchDetection
	+tests_video_HangoutHardwarePerf
	+tests_video_MultiplePlayback
	+tests_video_PlaybackPerf
	+tests_video_VideoCorruption
	+tests_video_VideoDecodeMemoryUsage
	+tests_video_VideoReload
	+tests_video_VideoSanity
	+tests_video_VideoSeek
	+tests_video_WebRtcCamera
	+tests_video_WebRtcMediaRecorder
	+tests_video_WebRtcPerf
	+tests_video_WebRtcPeerConnectionWithCamera
	+tests_video_YouTubeHTML5
	+tests_video_YouTubeMseEme
	+tests_video_YouTubePage
)

IUSE_TESTS_CELLULAR="
	cellular? (
		+tests_network_ChromeCellularEndToEnd
		+tests_network_ChromeCellularNetworkPresent
		+tests_network_ChromeCellularNetworkProperties
		+tests_network_ChromeCellularSmokeTest
		+tests_network_MobileSuspendResume
	)
"

IUSE_TESTS_SHILL="
	shill? (
		+tests_network_ChromeWifiEndToEnd
		+tests_network_FirewallHolePunch
		+tests_network_RackWiFiConnect
		+tests_network_RoamWifiEndToEnd
		+tests_network_RoamSuspendEndToEnd
	)
"

# This is here instead of in autotest-tests-tpm because it would be far more
# work and duplication to add telemetry dependencies there.
IUSE_TESTS_TPM="
	tpm? ( +tests_platform_Pkcs11InitOnLogin )
	tpm2? ( +tests_platform_Pkcs11InitOnLogin )
"

IUSE_TESTS="
	${IUSE_TESTS[*]}
	${IUSE_TESTS_CELLULAR}
	${IUSE_TESTS_SHILL}
	${IUSE_TESTS_TPM}
"

IUSE="
	${IUSE}
	${IUSE_TESTS}
"

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
	rsync -a --exclude=third_party/trace-viewer/test_data/ \
		"${SYSROOT}"/usr/local/telemetry/src/ "${TMP_DIR}"
	export PYTHONPATH="${TMP_DIR}/third_party/catapult/telemetry"
	autotest_src_prepare
}

src_configure() {
	cros-workon_src_configure
}
