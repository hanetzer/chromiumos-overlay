# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="3ae1a5fcf9f0daf6b9fd08572b93dd4503e8beb3"
CROS_WORKON_TREE="a91be2a0144af42b00a4353eb6a68ddaf1c0f0c2"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest

DESCRIPTION="ibus autotest"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

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

