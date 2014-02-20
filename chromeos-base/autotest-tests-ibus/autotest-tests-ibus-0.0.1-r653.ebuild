# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="d9aa4c34f8b3cc709dbecdf64c62bed4a4bb7e54"
CROS_WORKON_TREE="930cf0893898b143ab02135f10b6506a132cd745"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest

DESCRIPTION="ibus autotest"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="${IUSE} +autotest"

RDEPEND="
	chromeos-base/autotest-deps-ibus
	dev-python/pygtk
"

DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_desktopui_ImeLogin
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


