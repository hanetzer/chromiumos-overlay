# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a0273139e93287ea23ea400d0f9d9777bf7f00ef"
CROS_WORKON_TREE="9379c45d7b051b72817372c1edfae51c3a0dd3ee"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Autotest tests that require telemetry"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

# Enable autotest by default.
IUSE="+autotest"

RDEPEND="
	chromeos-base/autotest-tests
	chromeos-base/autotest-chrome
	chromeos-base/chromeos-chrome
	chromeos-base/telemetry
"

DEPEND="${RDEPEND}"

IUSE_TESTS=(
	# Tests that depend on telemetry
	+tests_telemetry_LoginTest
)

IUSE="${IUSE} ${IUSE_TESTS[*]}"

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_prepare() {
	# These tests assume that chromeos-base/telemetry is emerged and requires
	# that path to exist in order to build.
	export PYTHONPATH="${SYSROOT}/usr/local/telemetry/src/tools/telemetry"
	autotest_src_prepare
}
