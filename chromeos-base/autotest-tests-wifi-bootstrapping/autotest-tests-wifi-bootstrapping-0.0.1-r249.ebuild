# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="89c220368abfa8b8e3b967d9c39fc175b64802df"
CROS_WORKON_TREE="70ac58d251c4eeed26a3335a83ddeef66338da76"
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
	+tests_platform_CheckWiFiBootstrappingProcesses
	+tests_privetd_BasicDBusAPI
	+tests_privetd_CanConnectToWiFi
	+tests_privetd_PrivetInfo
	+tests_privetd_PrivetSetupFlow
	+tests_privetd_WebServerSanity
"

IUSE="${IUSE} ${IUSE_TESTS}"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"
