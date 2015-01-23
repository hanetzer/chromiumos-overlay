# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2324514d4a15579ffd4cf7c1395492272ea98599"
CROS_WORKON_TREE="9f77035683fc01c543074bd1901e06b387cd5aa9"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Tests for the leadership election service (leaderd)"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

IUSE_TESTS="
	+tests_leaderd_BasicDBusAPI
"

IUSE="${IUSE} ${IUSE_TESTS}"
