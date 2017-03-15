# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="9a8a977866e761a174e15bcdab2c2842ec26d26c"
CROS_WORKON_TREE="0475fa39fc5e9cda2316fab8d9ac3815ab1d2155"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Autotest server tests for shill"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="-chromeless_tests +autotest -chromeless_tty"

RDEPEND=""
DEPEND="${RDEPEND}
	!<chromeos-base/autotest-server-tests-0.0.2
	>=net-wireless/hostapd-2.3
"

SERVER_IUSE_TESTS="
	+tests_network_WiFi_AttenuatedPerf
	+tests_network_WiFi_BeaconInterval
	+tests_network_WiFi_BgscanBackoff
	+tests_network_WiFi_BluetoothScanPerf
	+tests_network_WiFi_BluetoothStreamPerf
	+tests_network_WiFi_ChannelScanDwellTime
	+tests_network_WiFi_ChaosConfigFailure
	+tests_network_WiFi_ChaosConnectDisconnect
	+tests_network_WiFi_ChaosLongConnect
	!chromeless_tty (
		!chromeless_tests (
			+tests_cellular_ChromeEndToEnd
			+tests_network_WiFi_ChromeEndToEnd
			+tests_network_WiFi_RoamEndToEnd
			+tests_network_WiFi_RoamSuspendEndToEnd
		)
	)
	+tests_network_WiFi_ConnectionIdentifier
	+tests_network_WiFi_CSADisconnect
	+tests_network_WiFi_DarkResumeActiveScans
	+tests_network_WiFi_DisableEnable
	+tests_network_WiFi_DisconnectClearsIP
	+tests_network_WiFi_DisconnectReason
	+tests_network_WiFi_DTIMPeriod
	+tests_network_WiFi_FastReconnectInDarkResume
	+tests_network_WiFi_GTK
	+tests_network_WiFi_HiddenRemains
	+tests_network_WiFi_HiddenScan
	+tests_network_WiFi_IBSS
	+tests_network_WiFi_LinkMonitorFailure
	+tests_network_WiFi_LowInitialBitrates
	+tests_network_WiFi_MalformedProbeResp
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
	+tests_network_WiFi_ReconnectInDarkResume
	+tests_network_WiFi_Regulatory
	+tests_network_WiFi_RegDomain
	+tests_network_WiFi_Roam
	+tests_network_WiFi_RoamDbus
	+tests_network_WiFi_RoamSuspendTimeout
	+tests_network_WiFi_RxFrag
	+tests_network_WiFi_ScanPerformance
	+tests_network_WiFi_SecChange
	+tests_network_WiFi_SetOptionalDhcpProperties
	+tests_network_WiFi_SimpleConnect
	+tests_network_WiFi_SuspendStress
	+tests_network_WiFi_TDLSPing
	+tests_network_WiFi_UpdateRouter
	+tests_network_WiFi_VerifyRouter
	+tests_network_WiFi_VisibleScan
	+tests_network_WiFi_WakeOnDisconnect
	+tests_network_WiFi_WakeOnSSID
	+tests_network_WiFi_WakeOnWiFiThrottling
	+tests_network_WiFi_WoWLAN
	+tests_network_WiFi_WMM
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
