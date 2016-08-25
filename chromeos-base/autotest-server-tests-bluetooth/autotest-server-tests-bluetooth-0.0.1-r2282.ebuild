# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e066f49a467b8df39d4e9a6cc5633ea1b343a8fe"
CROS_WORKON_TREE="2523de6ee01ac8d332e6684448252a4234e3f630"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Autotest server tests for Bluetooth"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="+autotest"

RDEPEND=""
DEPEND="${RDEPEND}
	!<chromeos-base/autotest-server-tests-0.0.2
"

SERVER_IUSE_TESTS="
	+tests_bluetooth_Sanity_AdapterPresent
	+tests_bluetooth_Sanity_DefaultState
	+tests_bluetooth_Sanity_Discoverable
	+tests_bluetooth_Sanity_Discovery
	+tests_bluetooth_Sanity_LEDiscovery
	+tests_bluetooth_Sanity_ValidAddress
	+tests_bluetooth_SDP_ServiceAttributeRequest
	+tests_bluetooth_SDP_ServiceBrowse
	+tests_bluetooth_SDP_ServiceSearchAttributeRequest
	+tests_bluetooth_SDP_ServiceSearchRequestBasic
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
