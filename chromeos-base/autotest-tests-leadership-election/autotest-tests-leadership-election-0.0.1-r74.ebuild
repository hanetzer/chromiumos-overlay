# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="094fd9d95f3b8b8954b8eefdb64375fd9a2a38f0"
CROS_WORKON_TREE="d4c1ae86b0d1b0135f3b0aeb57ee827178ed918a"
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
