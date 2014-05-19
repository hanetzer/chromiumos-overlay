# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="62c6764122961d2c838d026f1c98ce047bbc5897"
CROS_WORKON_TREE="79fc2437237cd2e043d9c9d39f8ec61fb259b683"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-debug cros-workon autotest

DESCRIPTION="Autotest tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+xset +tpmtools -chromeless_tty"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

LIBCHROME_VERS="242728"

# TODO(snanda): Remove xset dependence once power_LoadTest is switched over
# to use power manager
# TODO(semenzato): tpm-tools is included for hardware_TpmFirmware (and at this
# time only one binary is used, tpm_takeownership).  Once we have a testing
# image, a better way would be to add tpm-tools to the image.
#
# pygobject is used only in the following:
#   desktopui_ScreenLocker
#   hardware_BluetoothSemiAuto
#   network_3GActivate
#   network_3GDormancyDance
#   network_3GFailedConnect
#   network_3GRecoverFromGobiDesync
#   network_3GSafetyDance
#   network_3GSmokeTest
#   network_3GStressEnable
RDEPEND="
	tpmtools? ( app-crypt/tpm-tools )
	chromeos-base/autotest-deps
	!<=chromeos-base/autotest-factory-0.0.1-r4445
	!chromeless_tty? (
		chromeos-base/autotest-deps-glbench
		tests_graphics_GLMark2? ( chromeos-base/autotest-deps-glmark2 )
		tests_graphics_Piglit? ( chromeos-base/autotest-deps-piglit )
		tests_graphics_PiglitBVT? ( chromeos-base/autotest-deps-piglit )
	)
	chromeos-base/audiotest
	chromeos-base/shill-test-scripts
	dev-python/numpy
	dev-python/pygobject
	media-sound/sox
	xset? ( x11-apps/xset )
"

RDEPEND="${RDEPEND}
	tests_platform_RootPartitionsNotMounted? ( sys-apps/rootdev )
	tests_platform_RootPartitionsNotMounted? ( sys-fs/udev )
	tests_hardware_MemoryLatency? ( app-benchmarks/lmbench )
	tests_hardware_MemoryThroughput? ( app-benchmarks/lmbench )
	tests_hardware_TPMFirmware? ( chromeos-base/tpm_lite )
	tests_kernel_Lmbench? ( app-benchmarks/lmbench )
"

DEPEND="${RDEPEND}"

X86_IUSE_TESTS="
	+tests_security_SMMLocked
"

CLIENT_IUSE_TESTS="
	x86? ( ${X86_IUSE_TESTS} )
	amd64? ( ${X86_IUSE_TESTS} )
	+tests_compilebench
	+tests_crashme
	+tests_dbench
	+tests_ddtest
	+tests_disktest
	+tests_fsx
	+tests_hackbench
	+tests_iperf
	+tests_bonnie
	+tests_iozone
	+tests_netperf2
	+tests_netpipe
	+tests_scrashme
	+tests_sound_infrastructure
	+tests_sleeptest
	+tests_unixbench
	+tests_audio_AlsaLoopback
	+tests_audio_Aplay
	+tests_audio_CRASFormatConversion
	+tests_audio_CrasLoopback
	+tests_audio_LoopbackLatency
	+tests_audio_Microphone
	+tests_camera_V4L2
	+tests_autoupdate_CannedOmahaUpdate
	+tests_cellular_CdmaConfig
	+tests_cellular_DeferredRegistration
	+tests_cellular_Dummy
	+tests_cellular_ModemControl
	+tests_cellular_OutOfCreditsSubscriptionState
	+tests_cellular_ServiceName
	+tests_cellular_Signal
	+tests_cellular_Smoke
	+tests_cellular_ThroughputController
	+tests_cellular_Throughput
	+tests_cellular_ZeroSignal
	+tests_build_RootFilesystemSize
	+tests_desktopui_CrashyReboot
	+tests_desktopui_FontCache
	+tests_desktopui_GTK2Config
	+tests_desktopui_HangDetector
	+tests_desktopui_KillRestart
	+tests_desktopui_Respawn
	+tests_desktopui_SpeechSynthesisSemiAuto
	+tests_dummy_Pass
	+tests_dummy_Fail
	tests_example_UnitTest
	+tests_example_CrosTest
	+tests_firmware_FMap
	+tests_firmware_TouchMTB
	+tests_firmware_RomSize
	+tests_firmware_VbootCrypto
	+tests_flaky_test
	!chromeless_tty? (
		+tests_graphics_GLAPICheck
		+tests_graphics_GLBench
		+tests_graphics_GLMark2
		+tests_graphics_GpuReset
		+tests_graphics_KernelMemory
		+tests_graphics_LibDRM
		+tests_graphics_PerfControl
		+tests_graphics_Piglit
		+tests_graphics_PiglitBVT
		+tests_graphics_SanAngeles
		+tests_graphics_Sanity
		+tests_graphics_SyncControlTest
		+tests_graphics_VTSwitch
	)
	+tests_hardware_Ath3k
	+tests_hardware_Backlight
	+tests_hardware_Badblocks
	+tests_hardware_ch7036
	+tests_hardware_Components
	+tests_hardware_DeveloperRecovery
	+tests_hardware_DiskFirmwareUpgrade
	+tests_hardware_DiskSize
	+tests_hardware_EC
	+tests_hardware_EepromWriteProtect
	+tests_hardware_GobiGPS
	+tests_hardware_GPIOSwitches
	+tests_hardware_GPS
	+tests_hardware_I2CProbe
	+tests_hardware_Interrupt
	+tests_hardware_Keyboard
	+tests_hardware_LightSensor
	+tests_hardware_Memtester
	+tests_hardware_MemoryLatency
	+tests_hardware_MemoryThroughput
	+tests_hardware_MemoryTotalSize
	+tests_hardware_MultiReader
	+tests_hardware_RamFio
	+tests_hardware_RealtekCardReader
	+tests_hardware_Resolution
	+tests_hardware_SAT
	+tests_hardware_Smartctl
	+tests_hardware_SsdDetection
	+tests_hardware_StorageFio
	+tests_hardware_StorageStress
	+tests_hardware_StorageTrim
	+tests_hardware_StorageWearoutDetect
	+tests_hardware_TouchScreenPowerCycles
	tests_hardware_TouchScreenPresent
	+tests_hardware_TPMCheck
	tests_hardware_TPMFirmware
	+tests_hardware_Trackpad
	+tests_hardware_TrackpadFunction
	+tests_hardware_TrimIntegrity
	+tests_hardware_VideoDecodeCapable
	+tests_hardware_VideoOutSemiAuto
	+tests_hardware_Xrandr
	+tests_hardware_bma150
	+tests_kernel_Bootcache
	+tests_kernel_ConfigVerify
	+tests_kernel_CpufreqMinMax
	+tests_kernel_Delay
	+tests_kernel_fs_Inplace
	+tests_kernel_fs_Punybench
	+tests_kernel_IgnoreGptOptionServer
	+tests_kernel_Ktime
	+tests_kernel_Lmbench
	+tests_kernel_LowMemNotify
	+tests_kernel_Memory_Ramoop
	+tests_kernel_PerfEventRename
	+tests_kernel_SchedBandwith
	+tests_kernel_TPMPing
	+tests_kernel_HdParm
	+tests_kernel_ProtocolCheck
	+tests_kernel_CrosECSysfs
	+tests_kernel_CrosECSysfsAccel
	+tests_logging_CrashSender
	+tests_logging_KernelCrash
	+tests_logging_UdevCrash
	+tests_logging_UserCrash
	+tests_login_DBusCalls
	+tests_login_RetrieveActiveSessions
	+tests_login_SameSessionTwice
	+tests_login_SecondFactor
	+tests_network_3GActivate
	+tests_network_3GAssociation
	+tests_network_3GDisableWhileConnecting
	+tests_network_3GDisableGobiWhileConnecting
	+tests_network_3GDisconnectFailure
	+tests_network_3GDormancyDance
	+tests_network_3GFailedConnect
	+tests_network_3GGobiPorts
	+tests_network_3GIdentifiers
	+tests_network_3GModemControl
	+tests_network_3GModemPresent
	+tests_network_3GNoGobi
	+tests_network_3GRecoverFromGobiDesync
	+tests_network_3GSafetyDance
	+tests_network_3GScanningProperty
	+tests_network_3GSmokeTest
	+tests_network_3GStressEnable
	+tests_network_BasicProfileProperties
	+tests_network_CDMAActivate
	+tests_network_CheckCriticalProcesses
	+tests_network_ConnmanCromoCrash
	+tests_network_ConnmanIncludeExcludeMultiple
	+tests_network_ConnmanPowerStateTracking
	+tests_network_DefaultProfileCreation
	+tests_network_DefaultProfileServices
	+tests_network_DestinationVerification
	+tests_network_DhcpClasslessStaticRoute
	+tests_network_DhcpFailureWithStaticIP
	+tests_network_DhcpNak
	+tests_network_DhcpNegotiationSuccess
	+tests_network_DhcpNegotiationTimeout
	+tests_network_DhcpNonAsciiParameter
	+tests_network_DhcpRenew
	+tests_network_DhcpRenewWithOptionSubset
	+tests_network_DhcpStaticIP
	+tests_network_DhcpVendorEncapsulatedOptions
	+tests_network_DhcpWpadNegotiation
	+tests_network_DisableInterface
	+tests_network_EthCaps
	+tests_network_EthernetStressPlug
	+tests_network_GobiUncleanDisconnect
	+tests_network_Ipv6SimpleNegotiation
	+tests_network_LockedSIM
	+tests_network_LTEActivate
	+tests_network_ModemManagerSMS
	+tests_network_ModemManagerSMSSignal
	+tests_network_NegotiatedLANSpeed
	+tests_network_Portal
	+tests_network_ShillInitScripts
	+tests_network_SIMLocking
	+tests_network_SwitchCarrier
	+tests_network_TwoShills
	+tests_network_UdevRename
	+tests_network_VPNConnect
	+tests_network_WiFiCaps
	+tests_network_WiFiInvalidParameters
	+tests_network_WiMaxPresent
	+tests_network_WiMaxSmoke
	+tests_network_WlanDriver
	+tests_network_WlanHasIP
	+tests_network_netperf2
	+tests_p2p_ConsumeFiles
	+tests_p2p_ServeFiles
	+tests_p2p_ShareFiles
	+tests_platform_AccurateTime
	+tests_platform_AesThroughput
	+tests_platform_Attestation
	+tests_platform_BootPerf
	+tests_platform_CheckErrorsInLog
	+tests_platform_CleanShutdown
	+tests_platform_CompressedSwap
	+tests_platform_CompressedSwapPerf
	+tests_platform_CrosDisksArchive
	+tests_platform_CrosDisksDBus
	+tests_platform_CrosDisksFilesystem
	+tests_platform_CrosDisksFormat
	+tests_platform_CryptohomeBadPerms
	+tests_platform_CryptohomeChangePassword
	+tests_platform_CryptohomeFio
	+tests_platform_CryptohomeMount
	+tests_platform_CryptohomeMultiple
	+tests_platform_CryptohomeNonDirs
	+tests_platform_CryptohomeStress
	+tests_platform_CryptohomeTestAuth
	+tests_platform_DaemonsRespawn
	+tests_platform_DebugDaemonGetModemStatus
	+tests_platform_DebugDaemonGetNetworkStatus
	+tests_platform_DebugDaemonGetPerfData
	+tests_platform_DebugDaemonGetRoutes
	+tests_platform_DebugDaemonPing
	+tests_platform_DebugDaemonTracePath
	+tests_platform_DMVerityBitCorruption
	+tests_platform_DMVerityCorruption
	+tests_platform_EncryptedStateful
	+tests_platform_EvdevSynDropTest
	+tests_platform_ExternalUSBBootStress
	+tests_platform_ExternalUSBStress
	+tests_platform_FileNum
	+tests_platform_FilePerms
	+tests_platform_FileSize
	+tests_platform_HighResTimers
	+tests_platform_KernelVersion
	+tests_platform_KernelVersionByBoard
	+tests_platform_LibCBench
	+tests_platform_LogDupSuppression
	+tests_platform_MemCheck
	+tests_platform_NetParms
	+tests_platform_OpenSSLActual
	+tests_platform_OSLimits
	+tests_platform_PartitionCheck
	+tests_platform_Pkcs11InitUnderErrors
	+tests_platform_Pkcs11ChangeAuthData
	+tests_platform_Pkcs11Events
	+tests_platform_Pkcs11LoadPerf
	+tests_platform_Rootdev
	+tests_platform_RootPartitionsNotMounted
	+tests_platform_SessionManagerStateKeyGeneration
	+tests_platform_Shutdown
	+tests_platform_SuspendStress
	+tests_platform_TempFS
	+tests_platform_TLSDate
	+tests_platform_TLSDateActual
	+tests_platform_ToolchainOptions
	+tests_platform_TouchpadSynDrop
	+tests_platform_TPMEvict
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
	+tests_power_Resume
	+tests_power_Standby
	+tests_power_StatsCPUFreq
	+tests_power_StatsCPUIdle
	+tests_power_StatsUSB
	+tests_power_Status
	+tests_power_SuspendStress
	+tests_power_WakeupRTC
	+tests_power_x86Settings
	+tests_realtimecomm_GTalkAudioBench
	+tests_realtimecomm_GTalkLmiCamera
	+tests_realtimecomm_GTalkunittest
	+tests_security_AccountsBaseline
	+tests_security_ASLR
	+tests_security_ChromiumOSLSM
	+tests_security_DbusMap
	+tests_security_DbusOwners
	+tests_security_EnableChromeTesting
	+tests_security_Firewall
	+tests_security_HardlinkRestrictions
	+tests_security_HtpdateHTTP
	+tests_security_Minijail_seccomp
	+tests_security_Minijail0
	+tests_security_ModuleLocking
	+tests_security_OpenFDs
	+tests_security_OpenSSLBlacklist
	+tests_security_OpenSSLRegressions
	+tests_security_ProtocolFamilies
	+tests_security_ptraceRestrictions
	+tests_security_RendererSandbox
	+tests_security_ReservedPrivileges
	+tests_security_RestartJob
	+tests_security_RootCA
	+tests_security_RootfsOwners
	+tests_security_RootfsStatefulSymlinks
	+tests_security_RuntimeExecStack
	+tests_security_SandboxedServices
	+tests_security_SeccompSyscallFilters
	+tests_security_StatefulPermissions
	+tests_security_SuidBinaries
	+tests_security_SymlinkRestrictions
	+tests_security_SysLogPermissions
	+tests_security_SysVIPC
	+tests_security_x86Registers
	+tests_suite_HWConfig
	+tests_suite_HWQual
	+tests_test_Recall
"

IUSE_TESTS="${IUSE_TESTS}
	${CLIENT_IUSE_TESTS}
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
