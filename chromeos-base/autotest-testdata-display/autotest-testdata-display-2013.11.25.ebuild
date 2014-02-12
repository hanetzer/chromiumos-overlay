# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-constants

DESCRIPTION="Test data for display autotest tests."
HOMEPAGE="http://src.chromium.org"
SRC_URI="gs://chromeos-localmirror/distfiles/display_Resolution_test_data-${PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}

AUTOTEST_SERVER_SITE_TESTS="server/site_tests"

src_install() {
	# Install test data for display_Resolution test.
	# TODO(waihong): Move to a common directory such that tests can share.
	insinto "${AUTOTEST_BASE}/${AUTOTEST_SERVER_SITE_TESTS}/display_Resolution"
	doins -r "${WORKDIR}/display_Resolution_test_data"
}
