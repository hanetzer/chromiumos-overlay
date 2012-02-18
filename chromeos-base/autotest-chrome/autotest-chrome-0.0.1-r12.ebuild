# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="e5d93192720efcd74d9f9f25f460be17e572b2f6"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest Chrome tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="
	>chromeos-base/chromeos-chrome-19.0.1044.0_rc-r1
	!<=chromeos-base/chromeos-chrome-19.0.1044.0_rc-r1
	chromeos-base/flimflam-test
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_desktopui_BrowserTest
	+tests_desktopui_OMXTest
	+tests_desktopui_PyAutoFunctionalTests
	+tests_desktopui_PyAutoPerfTests
	+tests_desktopui_SyncIntegrationTests
	+tests_desktopui_UITest
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
