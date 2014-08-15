# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="ab583045d1e3e21da15eeb5152c2f808f4aea8ff"
CROS_WORKON_TREE="f08ef0f297922161dda842919f5d7509c65db6f7"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest

DESCRIPTION="Cellular autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.2
	chromeos-base/autotest-deps-cellular
	chromeos-base/shill-test-scripts
	dev-python/pygobject
	dev-python/pyusb
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_cellular_CdmaConfig
	+tests_cellular_DeferredRegistration
	+tests_cellular_ModemControl
	+tests_cellular_OutOfCreditsSubscriptionState
	+tests_cellular_ServiceName
	+tests_cellular_Signal
	+tests_cellular_Smoke
	+tests_cellular_Throughput
	+tests_cellular_ZeroSignal
	+tests_network_3GActivate
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
	+tests_network_ConnmanCromoCrash
	+tests_network_GobiUncleanDisconnect
	+tests_network_LTEActivate
	+tests_network_ModemManagerSMS
	+tests_network_ModemManagerSMSSignal
	+tests_network_SIMLocking
	+tests_network_SwitchCarrier
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
