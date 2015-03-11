# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="69ba0dd690f79d821b41b61bb736930e5d8a2274"
CROS_WORKON_TREE="2ecd8f294b4cd818f6a4b5ea62c3e968bf2bb42f"
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
