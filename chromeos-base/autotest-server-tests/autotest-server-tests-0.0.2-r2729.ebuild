# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="40a7d23601d5a0339e5cb6016420e952ba76852e"
CROS_WORKON_TREE="d6e1da309f17688d682aa1359e2745dd28a93f30"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Autotest server tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="-chromeless_tests +cheets +autotest +cellular -chromeless_tty cros_p2p debugd -moblab +power_management +readahead +tpm"

RDEPEND=""
DEPEND="${RDEPEND}
	!<chromeos-base/autotest-0.0.2
"

SERVER_IUSE_TESTS="
	+tests_android_ACTS
	+tests_android_EasySetup
	+tests_audio_AudioAfterReboot
	+tests_audio_AudioAfterSuspend
	+tests_audio_AudioArtifacts
	+tests_audio_AudioARCPlayback
	+tests_audio_AudioARCRecord
	+tests_audio_AudioBasicBluetoothPlayback
	+tests_audio_AudioBasicBluetoothPlaybackRecord
	+tests_audio_AudioBasicBluetoothRecord
	+tests_audio_AudioBasicExternalMicrophone
	+tests_audio_AudioBasicHDMI
	+tests_audio_AudioBasicHeadphone
	+tests_audio_AudioBasicInternalMicrophone
	+tests_audio_AudioBasicInternalSpeaker
	+tests_audio_AudioBasicUSBPlayback
	+tests_audio_AudioBasicUSBPlaybackRecord
	+tests_audio_AudioBasicUSBRecord
	+tests_audio_AudioBluetoothConnectionStability
	+tests_audio_AudioNodeSwitch
	+tests_audio_AudioQualityAfterSuspend
	+tests_audio_AudioVolume
	+tests_audio_AudioWebRTCLoopback
	+tests_audio_InternalCardNodes
	+tests_audio_MediaBasicVerification
	+tests_audio_PowerConsumption
	+tests_audiovideo_AVSync
	+tests_autoupdate_CatchBadSignatures
	+tests_autoupdate_Rollback
	+tests_bluetooth_AdapterLEAdvertising
	+tests_bluetooth_AdapterPairing
	+tests_bluetooth_AdapterStandalone
	+tests_brillo_gTests
	cellular? ( +tests_cellular_StaleModemReboot )
	cheets? (
		+tests_cheets_CTS
		+tests_cheets_GTS
	)
	+tests_component_UpdateFlash
	debugd? ( +tests_debugd_DevTools )
	!chromeless_tty? (
		!chromeless_tests? (
			+tests_desktopui_CrashyRebootServer
		)
	)
	+tests_display_EdidStress
	+tests_display_HDCPScreen
	+tests_display_HotPlugAtBoot
	+tests_display_HotPlugAtSuspend
	+tests_display_HotPlugNoisy
	+tests_display_LidCloseOpen
	+tests_display_NoEdid
	+tests_display_Resolution
	+tests_display_ResolutionList
	+tests_display_ServerChameleonConnection
	+tests_display_SuspendStress
	+tests_display_SwitchMode
	+tests_dummy_PassServer
	+tests_dummy_FailServer
	+tests_dummy_FlakyTestServer
	+tests_enterprise_CFM_Perf
	+tests_enterprise_CFM_Sanity
	+tests_enterprise_CFM_SessionStress
	+tests_enterprise_CFM_USBPeripheralHotplugDetect
	+tests_enterprise_CFM_USBPeripheralHotplugStress
	+tests_enterprise_CFM_VolumeChange
	+tests_enterprise_KioskEnrollmentServer
	+tests_enterprise_LongevityTrackerServer
	+tests_enterprise_RemoraRequisitionServer
	+tests_factory_Basic
	+tests_firmware_CgptStress
	+tests_firmware_CompareInstalledToShellBall
	+tests_firmware_ConsecutiveBoot
	+tests_firmware_ConsecutiveBootPowerButton
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
	+tests_firmware_ECHash
	+tests_firmware_ECKeyboard
	+tests_firmware_ECKeyboardReboot
	+tests_firmware_ECLidShutdown
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
	+tests_firmware_EventLog
	+tests_firmware_FAFTPrepare
	+tests_firmware_FAFTSetup
	+tests_firmware_FastbootErase
	+tests_firmware_FastbootReboot
	+tests_firmware_FMap
	+tests_firmware_FwScreenCloseLid
	+tests_firmware_FwScreenPressPower
	+tests_firmware_FWtries
	+tests_firmware_InvalidUSB
	+tests_firmware_LegacyRecovery
	+tests_firmware_Mosys
	+tests_firmware_RecoveryButton
	+tests_firmware_RollbackFirmware
	+tests_firmware_RollbackKernel
	+tests_firmware_RONormalBoot
	+tests_firmware_SelfSignedBoot
	+tests_firmware_SoftwareSync
	+tests_firmware_StandbyPowerConsumption
	tpm? ( +tests_firmware_TPMExtend )
	tpm? ( +tests_firmware_TPMVersionCheck )
	tpm? ( +tests_firmware_TPMKernelVersion )
	+tests_firmware_TryFwB
	+tests_firmware_TypeCCharging
	+tests_firmware_TypeCProbeUSB3
	+tests_firmware_UpdateFirmwareDataKeyVersion
	+tests_firmware_UpdateFirmwareVersion
	+tests_firmware_UpdateKernelDataKeyVersion
	+tests_firmware_UpdateKernelSubkeyVersion
	+tests_firmware_UpdateKernelVersion
	+tests_firmware_UserRequestRecovery
	+tests_generic_RebootTest
	+tests_graphics_PowerConsumption
	+tests_hardware_DiskFirmwareUpgrade
	+tests_hardware_MemoryIntegrity
	+tests_hardware_StorageQualBase
	+tests_hardware_StorageQualSuspendStress
	+tests_hardware_StorageQualTrimStress
	+tests_hardware_StorageStress
	+tests_kernel_EmptyLines
	+tests_kernel_ExternalUsbPeripheralsDetectionTest
	+tests_kernel_MemoryRamoop
	+tests_logging_GenerateCrashFiles
	moblab? ( +tests_moblab_RunSuite )
	cros_p2p? ( +tests_p2p_EndToEndTest )
	+tests_network_FirewallHolePunchServer
	+tests_platform_BootDevice
	+tests_platform_BootPerfServer
	+tests_platform_CompromisedStatefulPartition
	+tests_platform_CorruptRootfs
	+tests_platform_CrashStateful
	+tests_platform_ExternalUsbPeripherals
	+tests_platform_Flashrom
	+tests_platform_HWwatchdog
	+tests_platform_InstallTestImage
	+tests_platform_InternalDisplay
	+tests_platform_KernelErrorPaths
	+tests_platform_LabFirmwareUpdate
	power_management? (
		+tests_platform_PowerStatusStress
		+tests_power_DarkResumeShutdownServer
		+tests_power_DarkResumeDisplay
		+tests_power_DeferForFlashrom
	)
	+tests_platform_Powerwash
	+tests_platform_RebootAfterUpdate
	+tests_platform_RotationFps
	+tests_platform_ServoPowerStateController
	+tests_platform_SuspendResumeTiming
	+tests_platform_SyncCrash
	readahead? ( +tests_platform_UReadAheadServer )
	+tests_platform_Vpd
	+tests_power_BrightnessResetAfterReboot
	+tests_power_RPMTest
	+tests_provision_AutoUpdate
	+tests_security_kASLR
	+tests_sequences
	+tests_servohost_Reboot
	+tests_video_PowerConsumption
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_configure() {
	cros-workon_src_configure
}


