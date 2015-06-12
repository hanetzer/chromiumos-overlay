# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="41fe11ef6450a5c62379ea93fe58b57515f754ed"
CROS_WORKON_TREE="a68b478e1d30b7422131c2b8f5c6d1347d563c46"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest

DESCRIPTION="touchpad autotest"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="${IUSE} +autotest"

RDEPEND="
	chromeos-base/autotest-deps-touchpad
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_platform_GesturesRegressionTest
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_configure() {
	cros-workon_src_configure
}


