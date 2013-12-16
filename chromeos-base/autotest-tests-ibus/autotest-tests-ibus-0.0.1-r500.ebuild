# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="a44a9531f8dbd9c61d1f940397a816d628d4b369"
CROS_WORKON_TREE="02799a20b506969b8dedf44fa923b2822c94db25"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest

DESCRIPTION="ibus autotest"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

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


