# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs flag-o-matic

DESCRIPTION="Autotest tests"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~arm ~amd64"
IUSE="+autox buildcheck +xset +tpmtools opengles hardened"

# TODO(snanda): Remove xset dependence once power_LoadTest is switched over
# to use power manager
# TODO(semenzato): tpm-tools is included for hardware_TpmFirmware (and at this
# time only one binary is used, tpm_takeownership).  Once we have a testing
# image, a better way would be to add tpm-tools to the image.
RDEPEND="
  chromeos-base/autotest
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


# Ensure the configures run by autotest pick up the right config.site
export CONFIG_SITE=/usr/share/config.site
export AUTOTEST_SRC="${CHROMEOS_ROOT}/src/third_party/autotest/files"

# Pythonify the list of packages
function pythonify_test_list() {
	local result

	# NOTE: shell-like commenting of individual tests using grep
	result=$(for test in ${AUTOTEST_TEST_LIST}; do echo "${test},"|grep -v "^#"; done)

	echo ${result}|sed  -e 's/ //g'
}

# Create python package init files for top level test case dirs.
function touch_init_py() {
	local dirs=${1}
	for base_dir in $dirs
	do
		local sub_dirs="$(find ${base_dir} -maxdepth 1 -type d)"
		for sub_dir in ${sub_dirs}
		do
			touch ${sub_dir}/__init__.py
		done
		touch ${base_dir}/__init__.py
	done
}

function setup_cross_toolchain() {
	if tc-is-cross-compiler ; then
		tc-export CC CXX AR RANLIB LD NM STRIP
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	# TODO(fes): Check for /etc/hardened for now instead of the hardened
	# use flag because we aren't enabling hardened on the target board.
	# Rather, right now we're using hardened only during toolchain compile.
	# Various tests/etc. use %ebx in here, so we have to turn off PIE when
	# using the hardened compiler
	if use x86 ; then
		if use hardened ; then
			#CC="${CC} -nopie"
			append-flags -nopie
		fi
	fi
}

src_unpack() {
	local dst="${WORKDIR}/${P}"

	# pull in all the tests from this package
	mkdir -p "${S}"/client
	mkdir -p "${S}"/server

	cp -fpru "${AUTOTEST_SRC}"/client/{tests,site_tests,deps,profilers,config} "${S}"/client/ || die
	cp -fpru "${AUTOTEST_SRC}"/server/{tests,site_tests} "${S}"/server/ || die
	cp -fpru "${AUTOTEST_SRC}/global_config.ini" "${S}" || die
	cp -fpru "${AUTOTEST_SRC}/shadow_config.ini" "${S}" || die

	# create a working enviroment for pre-building
	ln -sf "${SYSROOT}"/usr/local/autotest/{conmux,tko,utils} "${S}"/
	# NOTE: in order to make autotest not notice it's running from /usr/local/, we need
	# to make sure the binaries are real, because they do the path magic
	local root_path base_path
	for base_path in client client/bin; do
		root_path="${SYSROOT}/usr/local/autotest/${base_path}"
		mkdir -p "${S}/${base_path}"

		# skip bin, because it is processed separately, and test-provided dirs
		for entry in $(ls "${root_path}" |grep -v "\(bin\|tests\|site_tests\|deps\|profilers\|config\)$"); do
			ln -sf "${root_path}/${entry}" "${S}/${base_path}/"
		done
	done
	# replace the important binaries with real copies
	for base_path in autotest autotest_client; do
		root_path="${SYSROOT}/usr/local/autotest/client/bin/${base_path}"
		rm "${S}/client/bin/${base_path}"
		cp -f ${root_path} "${S}/client/bin/${base_path}"
	done
}

src_configure() {
	sed "/^enable_server_prebuild/d" "${AUTOTEST_SRC}/global_config.ini" > \
		"${S}/global_config.ini"

	touch_init_py client/tests client/site_tests
	touch __init__.py

	# Cleanup checked-in binaries that don't support the target architecture
	[[ ${E_MACHINE} == "" ]] && return 0;
	rm -fv $( scanelf -RmyBF%a . | grep -v -e ^${E_MACHINE} )
}

src_compile() {
	setup_cross_toolchain

	if use opengles ; then
		graphics_backend=OPENGLES
	else
		graphics_backend=OPENGL
	fi

	TESTS=$(pythonify_test_list)
	einfo "Tests enabled: ${TESTS}"

	# Do not use sudo, it'll unset all your environment
	GRAPHICS_BACKEND="$graphics_backend" LOGNAME=${SUDO_USER} \
		client/bin/autotest_client --quiet --client_test_setup=${TESTS} \
		|| ! use buildcheck || die "Tests failed to build."

	# Cleanup some temp files after compiling
	find . -name '*.[ado]' -delete
}

src_install() {
	insinto /usr/local/autotest/client/
	doins -r "${S}"/client/{tests,site_tests,deps,profilers,config}
	insinto /usr/local/autotest/server/
	doins -r "${S}"/server/{tests,site_tests}
}
