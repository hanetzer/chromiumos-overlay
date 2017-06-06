# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="67ca2fbe02a39f41df72a492afdddde4ecb223f0"
CROS_WORKON_TREE="c5952672fd2b0eb89f304737ba3d802c8606b6e9"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="shill autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest +tpm tpm2"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
	chromeos-base/shill-test-scripts
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_network_CheckCriticalProcesses
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
	+tests_network_DhcpRequestHostName
	+tests_network_DhcpStaticIP
	+tests_network_DhcpVendorEncapsulatedOptions
	+tests_network_DhcpWpadNegotiation
	+tests_network_ShillInitScripts
	+tests_network_TwoShills
	+tests_network_WiFiInvalidParameters
	+tests_network_WlanDriver
	+tests_network_WlanHasIP
	tpm? ( +tests_network_VPNConnect )
	tpm2? ( +tests_network_VPNConnect )
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
