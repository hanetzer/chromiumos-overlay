# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="32ce46fb6c1905cfc8cbc4381515690d55af3b57"
CROS_WORKON_TREE="94bd48ece3280eb18a477767eb0d12a52a590939"
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
