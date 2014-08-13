# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="d47b4df397d017e920b7545062cd8e6a53dfc3d7"
CROS_WORKON_TREE="ec390b7ce232e79a6032053db0fe554f4f0f717f"
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


