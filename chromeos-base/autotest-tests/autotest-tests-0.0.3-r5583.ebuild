# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3b27dbc2358aef655e050a92510ff8e9e080bf81"
CROS_WORKON_TREE="655ec24b6f4c4a86749db0699e8308d5493ab67d"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic libchrome cros-debug cros-workon autotest

DESCRIPTION="Autotest tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-app_shell -chromeless_tty +crash_reporting +encrypted_stateful +network_time -ppp +passive_metrics +profile vaapi"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

# pygobject is used in the following tests:
#   firmware_TouchMTB
#   platform_CrosDisks*
RDEPEND="
	>=chromeos-base/autotest-deps-0.0.3
	!<=chromeos-base/autotest-factory-0.0.1-r4445
	dev-python/numpy
	dev-python/pygobject
	media-sound/sox
	vaapi? ( x11-libs/libva )
	x11-libs/libX11
"

RDEPEND="${RDEPEND}
	tests_dbench? ( dev-libs/libaio )
	tests_platform_RootPartitionsNotMounted? ( sys-apps/rootdev )
	tests_platform_RootPartitionsNotMounted? ( sys-fs/udev )
	tests_hardware_MemoryLatency? ( app-benchmarks/lmbench )
	tests_hardware_MemoryThroughput? ( app-benchmarks/lmbench )
	tests_kernel_Lmbench? ( app-benchmarks/lmbench )
"

DEPEND="${RDEPEND}"

X86_IUSE_TESTS="
	+tests_security_SMMLocked
"

CLIENT_IUSE_TESTS="
	x86? ( ${X86_IUSE_TESTS} )
	amd64? ( ${X86_IUSE_TESTS} )
	+tests_profiler_sync
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
	+tests_netpipe
	+tests_sleeptest
	+tests_unixbench
	+tests_autoupdate_CannedOmahaUpdate
	+tests_build_RootFilesystemSize
	+tests_camera_V4L2
	!chromeless_tty? (
		!app_shell? (
			+tests_desktopui_CrashyReboot
			+tests_desktopui_FontCache
			+tests_desktopui_HangDetector
			+tests_desktopui_KillRestart
			+tests_desktopui_Respawn
			+tests_desktopui_SpeechSynthesisSemiAuto
		)
	)
	+tests_display_ClientChameleonConnection
	+tests_dummy_Fail
	+tests_dummy_Pass
	+tests_example_CrosTest
	tests_example_UnitTest
	+tests_firmware_FMap
	+tests_firmware_RomSize
	+tests_firmware_TouchMTB
	+tests_firmware_VbootCrypto
	+tests_flaky_test
	+tests_hardware_Badblocks
	+tests_hardware_ch7036
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
	+tests_hardware_MemoryLatency
	+tests_hardware_MemoryThroughput
	+tests_hardware_MemoryTotalSize
	+tests_hardware_Memtester
	+tests_hardware_MultiReader
	+tests_hardware_PerfCounterVerification
	+tests_hardware_ProbeComponents
	+tests_hardware_RamFio
	+tests_hardware_RealtekCardReader
	+tests_hardware_Resolution
	+tests_hardware_SAT
	+tests_hardware_Smartctl
	+tests_hardware_SsdDetection
	+tests_hardware_StorageFio
	+tests_hardware_StorageTrim
	+tests_hardware_StorageWearoutDetect
	+tests_hardware_TouchScreenPowerCycles
	tests_hardware_TouchScreenPresent
	+tests_hardware_Trackpad
	+tests_hardware_TrackpadFunction
	+tests_hardware_TrimIntegrity
	+tests_hardware_VideoDecodeCapable
	+tests_hardware_VideoOutSemiAuto
	+tests_hardware_Xrandr
	+tests_kernel_Bootcache
	+tests_kernel_ConfigVerify
	ppp? ( +tests_kernel_ConfigVerifyPPP )
	+tests_kernel_CpufreqMinMax
	+tests_kernel_CrosECSysfs
	+tests_kernel_CrosECSysfsAccel
	+tests_kernel_Delay
	+tests_kernel_fs_Inplace
	+tests_kernel_fs_Punybench
	+tests_kernel_HdParm
	+tests_kernel_IgnoreGptOptionServer
	+tests_kernel_Ktime
	+tests_kernel_Lmbench
	+tests_kernel_LowMemNotify
	+tests_kernel_Memory_Ramoop
	+tests_kernel_PerfEventRename
	+tests_kernel_ProtocolCheck
	+tests_kernel_SchedBandwith
	+tests_kernel_SchedCgroups
	+tests_kernel_VbootContextEC
	crash_reporting? (
		+tests_logging_CrashSender
		+tests_logging_KernelCrash
		+tests_logging_UdevCrash
		+tests_logging_UserCrash
	)
	!chromeless_tty? (
		+tests_login_RetrieveActiveSessions
		+tests_login_SameSessionTwice
	)
	+tests_network_EthCaps
	+tests_network_EthernetStressPlug
	+tests_network_Ipv6SimpleNegotiation
	+tests_network_NegotiatedLANSpeed
	+tests_network_UdevRename
	+tests_network_WiFiCaps
	+tests_platform_AccurateTime
	+tests_platform_AesThroughput
	+tests_platform_BootPerf
	+tests_platform_CheckErrorsInLog
	+tests_platform_CheckCriticalProcesses
	passive_metrics? ( +tests_platform_CheckMetricsProcesses )
	network_time? ( +tests_platform_CheckTLSDateProcesses )
	+tests_platform_CleanShutdown
	+tests_platform_CompressedSwap
	+tests_platform_CompressedSwapPerf
	+tests_platform_DaemonsRespawn
	+tests_platform_DMVerityBitCorruption
	+tests_platform_DMVerityCorruption
	encrypted_stateful? ( +tests_platform_EncryptedStateful )
	!chromeless_tty? ( +tests_platform_EvdevSynDropTest )
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
	+tests_platform_LogNonKernelKmsg
	+tests_platform_MemCheck
	+tests_platform_MemoryMonitor
	chromeless_tty? ( +tests_platform_MetricsUploader )
	+tests_platform_NetParms
	+tests_platform_OpenSSLActual
	+tests_platform_OSLimits
	+tests_platform_PartitionCheck
	profile? (
		+tests_platform_Perf
		+tests_platform_Quipper
	)
	+tests_platform_Rootdev
	+tests_platform_RootPartitionsNotMounted
	!chromeless_tty? ( +tests_platform_SessionManagerStateKeyGeneration )
	+tests_platform_TempFS
	network_time? (
		+tests_platform_TLSDate
		+tests_platform_TLSDateActual
	)
	+tests_platform_ToolchainOptions
	+tests_platform_TouchpadSynDrop
        +tests_platform_UdevVars
	!chromeless_tty? (
		+tests_realtimecomm_GTalkAudioBench
		+tests_realtimecomm_GTalkLmiCamera
		+tests_realtimecomm_GTalkunittest
	)
	+tests_suite_HWConfig
	+tests_suite_HWQual
	+tests_touch_WakeupSource
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
