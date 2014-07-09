# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4fbba52bc81ae1a7f6bacb05ee81e4369ee4a5f5"
CROS_WORKON_TREE="0bd0b3a73b0296367b8e5e23444dee3d5d674980"
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
IUSE="+autotest -chromeless_tty"

RDEPEND=""
DEPEND="${RDEPEND}
	!<chromeos-base/autotest-server-tests-0.0.2
"

SERVER_IUSE_TESTS="
	+tests_network_WiFi_AttenuatedPerf
	+tests_network_WiFi_BeaconInterval
	+tests_network_WiFi_BgscanBackoff
	+tests_network_WiFi_ChannelScanDwellTime
	+tests_network_WiFi_ChaosConfigFailure
	+tests_network_WiFi_ChaosConnectDisconnect
	+tests_network_WiFi_ChaosLongConnect
	!chromeless_tty (
		+tests_network_WiFi_ChromeEndToEnd
	)
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
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
