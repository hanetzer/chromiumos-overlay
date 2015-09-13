# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e01cc1289c9fac5b979950068a0fd931bde9c4fd"
CROS_WORKON_TREE="58dfd48091c998f0caa7f6bf074a2248a111b7dc"
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
