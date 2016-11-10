# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3bdcfbda405a1e9df004938b192d55c15c252236"
CROS_WORKON_TREE="3ef334a864bf9d021c3c2739b174990e9631b5c3"
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
