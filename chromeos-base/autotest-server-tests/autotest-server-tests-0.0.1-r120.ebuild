# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="008f1336f9b59055071da03da8a4cb4551188a12"
CROS_WORKON_TREE="bc4ffca5fa9e5732e861f1e4bb7a06400a3e5554"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-debug cros-workon autotest

DESCRIPTION="Autotest tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND=""
DEPEND="${RDEPEND}
	!<chromeos-base/autotest-0.0.2
"

SERVER_IUSE_TESTS="
	+tests_autoupdate_CatchBadSignatures
	+tests_autoupdate_Rollback
	+tests_bluetooth_Sanity_AdapterPresent
	+tests_bluetooth_Sanity_DefaultState
	+tests_bluetooth_Sanity_Discoverable
	+tests_bluetooth_Sanity_Discovery
	+tests_bluetooth_Sanity_ValidAddress
	+tests_bluetooth_SDP_ServiceAttributeRequest
	+tests_bluetooth_SDP_ServiceSearchRequestBasic
	+tests_cellular_StaleModemReboot
	+tests_chromeperf_PGOPageCycler
	+tests_desktopui_CrashyRebootServer
	+tests_desktopui_EnterprisePolicyServer
	+tests_desktopui_PyAutoPerf
	+tests_display_EdidStress
	+tests_display_HotPlugAtBoot
	+tests_display_HotPlugAtSuspend
	+tests_display_Resolution
	+tests_dummy_FailServer
	+tests_dummy_FlakyTestServer
	+tests_factory_Basic
	+tests_firmware_CgptState
	+tests_firmware_CgptStress
	+tests_firmware_ConsecutiveBoot
	+tests_firmware_CorruptBothFwBodyAB
	+tests_firmware_CorruptBothFwSigAB
	+tests_firmware_CorruptBothKernelAB
	+tests_firmware_CorruptFwBodyA
	+tests_firmware_CorruptFwBodyB
	+tests_firmware_CorruptFwSigA
	+tests_firmware_CorruptFwSigB
	+tests_firmware_CorruptKernelA
	+tests_firmware_CorruptKernelB
	+tests_firmware_DevBootUSB
	+tests_firmware_DevMode
	+tests_firmware_DevModeStress
	+tests_firmware_DevScreenTimeout
	+tests_firmware_DevTriggerRecovery
	+tests_firmware_ECBattery
	+tests_firmware_ECBootTime
	+tests_firmware_ECCharging
	+tests_firmware_ECHash
	+tests_firmware_ECKeyboard
	+tests_firmware_ECLidSwitch
	+tests_firmware_ECPeci
	+tests_firmware_ECPowerButton
	+tests_firmware_ECPowerG3
	+tests_firmware_ECSharedMem
	+tests_firmware_ECThermal
	+tests_firmware_ECUsbPorts
	+tests_firmware_ECWakeSource
	+tests_firmware_ECWatchdog
	+tests_firmware_ECWriteProtect
	+tests_firmware_FAFTPrepare
	+tests_firmware_FAFTSetup
	+tests_firmware_FwScreenCloseLid
	+tests_firmware_FwScreenPressPower
	+tests_firmware_InvalidUSB
	+tests_firmware_LegacyRecovery
	+tests_firmware_RecoveryButton
	+tests_firmware_RollbackFirmware
	+tests_firmware_RollbackKernel
	+tests_firmware_RONormalBoot
	+tests_firmware_SelfSignedBoot
	+tests_firmware_SoftwareSync
	+tests_firmware_TPMVersionCheck
	+tests_firmware_TryFwB
	+tests_firmware_UpdateECBin
	+tests_firmware_UpdateFirmwareDataKeyVersion
	+tests_firmware_UpdateFirmwareVersion
	+tests_firmware_UpdateKernelDataKeyVersion
	+tests_firmware_UpdateKernelSubkeyVersion
	+tests_firmware_UpdateKernelVersion
	+tests_firmware_UserRequestRecovery
	+tests_hardware_MemoryIntegrity
	+tests_kernel_EmptyLines
	+tests_kernel_MemoryRamoop
	+tests_network_WiFi_AttenuatedPerf
	+tests_network_WiFi_BeaconInterval
	+tests_network_WiFi_BgscanBackoff
	+tests_network_WiFi_ChannelScanDwellTime
	+tests_network_WiFi_ChaosConfigFailure
	+tests_network_WiFi_ChaosConnectDisconnect
	+tests_network_WiFi_ChaosLongConnect
	+tests_network_WiFi_ConnectionIdentifier
	+tests_network_WiFi_DisableEnable
	+tests_network_WiFi_DisconnectClearsIP
	+tests_network_WiFi_DTIMPeriod
	+tests_network_WiFi_GTK
	+tests_network_WiFi_HiddenRemains
	+tests_network_WiFi_HiddenScan
	+tests_network_WiFi_IBSS
	+tests_network_WiFi_LowInitialBitrates
	+tests_network_WiFi_MaskedBSSID
	+tests_network_WiFi_MissingBeacons
	+tests_network_WiFi_MultiAuth
	+tests_network_WiFi_OverlappingBSSScan
	+tests_network_WiFi_Perf
	+tests_network_WiFi_PMKSACaching
	+tests_network_WiFi_Powersave
	+tests_network_WiFi_Prefer5Ghz
	+tests_network_WiFi_ProfileBasic
	+tests_network_WiFi_ProfileGUID
	+tests_network_WiFi_PTK
	+tests_network_WiFi_RateControl
	+tests_network_WiFi_Reassociate
	+tests_network_WiFi_Regulatory
	+tests_network_WiFi_Roam
	+tests_network_WiFi_RoamSuspendTimeout
	+tests_network_WiFi_RxFrag
	+tests_network_WiFi_ScanPerformance
	+tests_network_WiFi_SecChange
	+tests_network_WiFi_SimpleConnect
	+tests_network_WiFi_TDLSPing
	+tests_network_WiFi_VerifyRouter
	+tests_network_WiFi_VisibleScan
	+tests_network_WiFi_WMM
	+tests_platform_BootDevice
	+tests_platform_BootPerfServer
	+tests_platform_CorruptRootfs
	+tests_platform_CrashStateful
	+tests_platform_HWwatchdog
	+tests_platform_InstallTestImage
	+tests_platform_KernelErrorPaths
	+tests_platform_PowerStatusStress
	+tests_platform_Powerwash
	+tests_platform_RebootAfterUpdate
	+tests_platform_ServoPowerStateController
	+tests_platform_SyncCrash
	+tests_platform_UReadAheadServer
	+tests_platform_Vpd
	+tests_power_DarkResumeShutdownServer
	+tests_power_RPMTest
	+tests_power_SuspendShutdown
	+tests_security_kASLR
	+tests_suites
	+tests_telemetry_AFDOGenerate
	+tests_telemetry_Benchmarks
	+tests_telemetry_CrosTests
	+tests_telemetry_GpuTests
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_configure() {
	cros-workon_src_configure
}


