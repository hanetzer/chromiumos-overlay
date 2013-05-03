# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a9b225bfd594b0c5eb4b410eb18c8cb354046fec"
CROS_WORKON_TREE="ef4c8ca1cf68cbb7e1ad7061b6269c7b9d759d20"
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
