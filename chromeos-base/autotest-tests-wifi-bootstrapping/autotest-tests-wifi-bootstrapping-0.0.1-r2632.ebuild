# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="eea5fe1b4990a1608a384922e5857621e2e11c35"
CROS_WORKON_TREE="001b7d7cec681b592bb9c9edd2b0b97b833ebb84"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="autotests for the WiFi bootstrapping process"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest peerd wifi_bootstrapping"
# We depend on peerd to provide some services, so enable those
# tests as well.
REQUIRED_USE="wifi_bootstrapping? ( peerd )"

IUSE_TESTS="
	+tests_apmanager_CheckAPProcesses
	+tests_buffet_PrivetInfo
	+tests_buffet_PrivetSetupFlow
	+tests_buffet_WebServerSanity
	+tests_platform_CheckWiFiBootstrappingProcesses
"

IUSE="${IUSE} ${IUSE_TESTS}"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"
