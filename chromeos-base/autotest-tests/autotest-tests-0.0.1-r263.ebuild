# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="8d31f9841f106543a9880a97d6e1252bdcc3ae56"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest tests"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

IUSE="+autox +xset +tpmtools hardened"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

# TODO(snanda): Remove xset dependence once power_LoadTest is switched over
# to use power manager
# TODO(semenzato): tpm-tools is included for hardware_TpmFirmware (and at this
# time only one binary is used, tpm_takeownership).  Once we have a testing
# image, a better way would be to add tpm-tools to the image.
RDEPEND="
  chromeos-base/flimflam
  autox? ( chromeos-base/autox )
  xset? ( x11-apps/xset )
  tpmtools? ( app-crypt/tpm-tools )
"

RDEPEND="${RDEPEND}
  tests_audiovideo_PlaybackRecordSemiAuto? ( media-sound/pulseaudio )
  tests_platform_MiniJailRootCapabilities? ( sys-libs/libcap )
"

# TODO(hungte) To remove the dependency of autotest-approved-components without
# breaking build system, we temporary make it an empty package in 0.1.0. Please
# remove the dependency when everyone has switched over to use new
# hareware_Components.
RDEPEND="${RDEPEND}
  tests_hardware_Components?
	( >=chromeos-base/autotest-approved-components-0.1.0 )
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_compilebench
	+tests_dbench
	+tests_disktest
	+tests_fsx
	+tests_hackbench
	+tests_iperf
	tests_ltp
	+tests_netperf2
	+tests_netpipe
	+tests_sleeptest
	+tests_unixbench
	+tests_audiovideo_FFMPEG
	+tests_audiovideo_Microphone
	+tests_audiovideo_PlaybackRecordSemiAuto
	+tests_audiovideo_V4L2
	+tests_build_RootFilesystemSize
	+tests_desktopui_ChromeFirstRender
	+tests_desktopui_ChromeSemiAuto
	+tests_desktopui_FlashSanityCheck
	+tests_desktopui_IBusTest
	+tests_desktopui_ImeTest
	+tests_desktopui_KillRestart
	+tests_desktopui_ScreenLocker
	+tests_desktopui_SpeechSynthesisSemiAuto
	+tests_desktopui_SunSpiderBench
	+tests_desktopui_UrlFetch
	+tests_desktopui_V8Bench
	+tests_desktopui_WindowManagerFocusNewWindows
	+tests_desktopui_WindowManagerHotkeys
	+tests_dummy_Fail
	+tests_dummy_Pass
	tests_example_UnitTest
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
	+tests_firmware_RomSize
	tests_firmware_VbootCrypto
	+tests_graphics_GLAPICheck
	+tests_graphics_GLBench
	+tests_graphics_O3DSelenium
	+tests_graphics_SanAngeles
	+tests_graphics_TearTest
	+tests_graphics_WebGLConformance
	+tests_graphics_WindowManagerGraphicsCapture
	+tests_hardware_Ath3k
	+tests_hardware_Backlight
	+tests_hardware_BluetoothSemiAuto
	+tests_hardware_ch7036
	+tests_hardware_Components
	+tests_hardware_DeveloperRecovery
	+tests_hardware_DiskSize
	+tests_hardware_EepromWriteProtect
	+tests_hardware_ExternalDrives
	+tests_hardware_GobiGPS
	+tests_hardware_GPIOSwitches
	+tests_hardware_GPS
	+tests_hardware_Keyboard
	+tests_hardware_MemoryThroughput
	+tests_hardware_MemoryTotalSize
	+tests_hardware_MultiReader
	+tests_hardware_RealtekCardReader
	+tests_hardware_Resolution
	+tests_hardware_SAT
	+tests_hardware_SsdDetection
	+tests_hardware_StorageFio
	+tests_hardware_USB20
	tests_hardware_TPM
	+tests_hardware_TPMCheck
	tests_hardware_TPMFirmware
	+tests_hardware_USB20
	+tests_hardware_UsbPlugIn
	+tests_hardware_VideoOutSemiAuto
	+tests_hardware_bma150
	+tests_hardware_tsl2563
	+tests_logging_CrashSender
	+tests_logging_CrashServices
	+tests_logging_KernelCrash
	+tests_logging_KernelCrashServer
	+tests_logging_LogVolume
	+tests_logging_UserCrash
	+tests_logging_UncleanShutdown
	+tests_logging_UncleanShutdownServer
	+tests_login_Backdoor
	+tests_login_BadAuthentication
	+tests_login_ChromeProfileSanitary
	+tests_login_CryptohomeIncognitoMounted
	+tests_login_CryptohomeIncognitoUnmounted
	+tests_login_CryptohomeMounted
	+tests_login_CryptohomeUnmounted
	+tests_login_DBusCalls
	+tests_login_LoginSuccess
	+tests_login_LogoutProcessCleanup
	+tests_login_RemoteLogin
	+tests_login_SecondFactor
	+tests_network_3GLoadFirmware
	+tests_network_3GModemPresent
	+tests_network_3GSmokeTest
	+tests_network_ConnmanIncludeExcludeMultiple
	+tests_network_DhclientLeaseTestCase
	+tests_network_DisableInterface
	+tests_network_NegotiatedLANSpeed
	+tests_network_Ping
	+tests_network_UdevRename
	+tests_network_WiFiCaps
	+tests_network_WiFiMatFunc
	+tests_network_WiFiSecMat
	+tests_network_WiFiSmokeTest
	+tests_network_WifiAuthenticationTests
	+tests_network_WlanHasIP
	+tests_network_netperf2
	+tests_platform_AccurateTime
	+tests_platform_AesThroughput
	+tests_platform_BootPerf
	+tests_platform_BootPerfServer
	+tests_platform_CheckErrorsInLog
	+tests_platform_CleanShutdown
	+tests_platform_CryptohomeChangePassword
	+tests_platform_CryptohomeMount
	+tests_platform_CryptohomeTestAuth
	+tests_platform_CryptohomeTPMReOwnServer
	+tests_platform_DMVerityCorruption
	+tests_platform_DaemonsRespawn
	+tests_platform_DiskIterate
	+tests_platform_FileNum
	+tests_platform_FilePerms
	+tests_platform_FileSize
	+tests_platform_KernelErrorPaths
	+tests_platform_KernelVersion
	+tests_platform_MemCheck
	+tests_platform_MiniJailCmdLine
	+tests_platform_MiniJailPidNamespace
	+tests_platform_MiniJailPtraceDisabled
	+tests_platform_MiniJailReadOnlyFS
	+tests_platform_MiniJailRootCapabilities
	+tests_platform_MiniJailUidGid
	+tests_platform_MiniJailVfsNamespace
	+tests_platform_NetParms
	+tests_platform_OSLimits
	+tests_platform_PartitionCheck
	+tests_platform_ProcessPrivileges
	+tests_platform_Rootdev
	+tests_platform_Shutdown
	+tests_platform_StackProtector
	+tests_platform_TempFS
	+tests_power_Backlight
	+tests_power_BatteryCharge
	+tests_power_CPUFreq
	+tests_power_CPUIdle
	+tests_power_Draw
	+tests_power_Idle
	+tests_power_IdleServer
	+tests_power_LoadTest
	+tests_power_ProbeDriver
	+tests_power_Resume
	+tests_power_StatsCPUFreq
	+tests_power_StatsCPUIdle
	+tests_power_StatsUSB
	+tests_power_Status
	+tests_power_SuspendResume
	+tests_power_x86Settings
	+tests_realtimecomm_GTalkAudioBench
	+tests_realtimecomm_GTalkAudioPlayground
	+tests_realtimecomm_GTalkPlayground
	+tests_realtimecomm_GTalkunittest
	+tests_security_DbusOwners
	+tests_security_NetworkListeners
	+tests_security_RendererSandbox
	+tests_security_ReservedPrivileges
	+tests_security_RestartJob
	+tests_security_RootfsOwners
	+tests_security_SuidBinaries
	+tests_suites
	+tests_suite_Factory
	+tests_suite_HWConfig
	+tests_suite_HWQual
	+tests_suite_Smoke
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_PROJECT=autotest
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
