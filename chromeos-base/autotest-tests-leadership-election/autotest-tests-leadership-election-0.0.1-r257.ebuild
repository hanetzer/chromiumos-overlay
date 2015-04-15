# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9e6907d69c413c2a57cc32a3d153c23b432325bf"
CROS_WORKON_TREE="0c0b82f235680c883ea28a1b3476a24b518301e2"
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
	+tests_leaderd_Election
"

IUSE="${IUSE} ${IUSE_TESTS}"
