# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="4121d1f4b59cbe309d4671398a336f7a8005e3c7"
CROS_WORKON_TREE="51138514adbf6f732cb8e344c34f1b952ee8ce6e"
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
