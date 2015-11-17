# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="8bb71497c37767a62c6b34c1aacf1069fb6f650c"
CROS_WORKON_TREE="93e74e054caf60208301f4ce99babf6bda4d4bec"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest touchpad deps"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST="touchpad-tests"
AUTOTEST_CONFIG_LIST=
AUTOTEST_PROFILERS_LIST=

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/touchpad-tests
RDEPEND="
	x11-drivers/touchpad-tests
	chromeos-base/touch_firmware_test
	chromeos-base/mttools
"

DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}


