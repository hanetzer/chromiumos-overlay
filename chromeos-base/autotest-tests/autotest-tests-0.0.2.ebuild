# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest tests"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~arm ~amd64"
IUSE="+autox +xset +tpmtools opengles hardened"

# TODO(snanda): Remove xset dependence once power_LoadTest is switched over
# to use power manager
# TODO(semenzato): tpm-tools is included for hardware_TpmFirmware (and at this
# time only one binary is used, tpm_takeownership).  Once we have a testing
# image, a better way would be to add tpm-tools to the image.
RDEPEND="
  chromeos-base/crash-dumper
  dev-cpp/gtest
  dev-lang/python
  autox? ( chromeos-base/autox )
  xset? ( x11-apps/xset )
  tpmtools? ( app-crypt/tpm-tools )
  "

DEPEND="
	${RDEPEND}"

AUTOTEST_TEST_LIST="
	compilebench
	dbench
	disktest
	fsx
	hackbench
	iperf
	ltp
	netperf2
	netpipe
	unixbench
	audiovideo_FFMPEG
	audiovideo_PlaybackRecordSemiAuto
	audiovideo_V4L2
	build_RootFilesystemSize
	desktopui_BrowserTest
	desktopui_ChromeFirstRender
	desktopui_ChromeSemiAuto
	desktopui_FlashSanityCheck
	desktopui_IBusTest
	desktopui_KillRestart
	desktopui_PageCyclerTests
	desktopui_ScreenSaverUnlock
	desktopui_SpeechSynthesisSemiAuto
	desktopui_SunSpiderBench
	desktopui_UITest
	desktopui_UrlFetch
	desktopui_V8Bench
	desktopui_WindowManagerFocusNewWindows
	desktopui_WindowManagerHotkeys
	#example_UnitTest
	factory_Camera
	factory_DeveloperRecovery
	factory_Display
	factory_Dummy
	factory_ExternalStorage
	factory_Fail
	factory_Keyboard
	factory_Leds
	factory_RebootStub
	factory_Review
	factory_ScriptWrapper
	factory_ShowTestResults
	factory_Touchpad
	factory_Wipe
	firmware_RomSize
	#firmware_VbootCrypto
	#graphics_GLAPICheck
	graphics_GLBench
	#graphics_O3DSelenium
	#graphics_SanAngeles
	graphics_TearTest
	#graphics_WebGLConformance
	graphics_WindowManagerGraphicsCapture
	hardware_Backlight
	hardware_BluetoothSemiAuto
	hardware_Components
	hardware_DeveloperRecovery
	hardware_DiskSize
	hardware_EepromWriteProtect
	hardware_GPIOSwitches
	hardware_GPS
	hardware_MemoryThroughput
	hardware_MemoryTotalSize
	hardware_Resolution
	hardware_SAT
	hardware_SsdDetection
	hardware_StorageFio
	#hardware_TPM
	#hardware_TPMFirmware
	hardware_UsbPlugIn
	hardware_VideoOutSemiAuto
	hardware_bma150
	hardware_tsl2563
	logging_KernelCrash
	logging_LogVolume
	logging_UserCrash
	login_Backdoor
	login_BadAuthentication
	login_ChromeProfileSanitary
	login_CryptohomeIncognitoMounted
	login_CryptohomeMounted
	login_CryptohomeUnmounted
	login_LoginSuccess
	login_LogoutProcessCleanup
	login_RemoteLogin
	network_3GSmokeTest
	network_ConnmanIncludeExcludeMultiple
	network_DhclientLeaseTestCase
	network_DisableInterface
	network_NegotiatedLANSpeed
	network_Ping
	network_UdevRename
	network_WiFiCaps
	network_WiFiSmokeTest
	network_WifiAuthenticationTests
	network_WlanHasIP
	network_netperf2
	platform_AccurateTime
	platform_AesThroughput
	platform_BootPerf
	platform_CheckErrorsInLog
	platform_CleanShutdown
	platform_CryptohomeChangePassword
	platform_CryptohomeMount
	platform_CryptohomeTestAuth
	platform_DMVerityCorruption
	platform_DaemonsRespawn
	platform_DiskIterate
	platform_FileNum
	platform_FilePerms
	platform_FileSize
	platform_KernelVersion
	platform_MemCheck
	platform_MiniJailCmdLine
	platform_MiniJailPidNamespace
	platform_MiniJailPtraceDisabled
	platform_MiniJailReadOnlyFS
	platform_MiniJailRootCapabilities
	platform_MiniJailUidGid
	platform_MiniJailVfsNamespace
	platform_NetParms
	platform_OSLimits
	platform_PartitionCheck
	platform_ProcessPrivileges
	platform_Shutdown
	platform_StackProtector
	platform_TempFS
	power_Backlight
	power_BatteryCharge
	power_CPUFreq
	power_CPUIdle
	power_Draw
	power_Idle
	power_LoadTest
	power_Resume
	power_StatsCPUFreq
	power_StatsCPUIdle
	power_StatsUSB
	power_Status
	power_x86Settings
	realtimecomm_GTalkAudioBench
	realtimecomm_GTalkAudioPlayground
	realtimecomm_GTalkPlayground
	realtimecomm_GTalkunittest
	security_RendererSandbox
"

CROS_WORKON_PROJECT=autotest
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

