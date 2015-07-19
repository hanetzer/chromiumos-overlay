# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b57c64e2a2b8e9abd1295bb810447a246ae2bb9c"
CROS_WORKON_TREE="b3f89d5858e6c2c22a418014889aa2ec858b283b"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="autotests for cloud services related functionality"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

IUSE_TESTS="
	+tests_buffet_BasicDBusAPI
	+tests_buffet_Registration
	+tests_buffet_RestartWhenRegistered
	+tests_buffet_RefreshAccessToken
	+tests_buffet_InvalidCredentials
	+tests_buffet_IntermittentConnectivity
"

IUSE="${IUSE} ${IUSE_TESTS}"
