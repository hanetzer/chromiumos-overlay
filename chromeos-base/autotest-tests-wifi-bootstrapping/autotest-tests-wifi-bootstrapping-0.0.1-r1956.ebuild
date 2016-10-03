# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="abd3b05597bfa2e5244209b7f5146900a58290a9"
CROS_WORKON_TREE="47e87e5cb91b8b52ab91ec59f7a18f818aa1ef96"
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
