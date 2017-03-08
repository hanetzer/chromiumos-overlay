# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="7c16f8c074cb661d71a2a6474ea4627cf1a536bf"
CROS_WORKON_TREE="ac6b991abf7535e9f3f5f44008dd834c6fa8982f"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest cellular deps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST="fakegudev fakemodem"
AUTOTEST_CONFIG_LIST=
AUTOTEST_PROFILERS_LIST=

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

RDEPEND="!<chromeos-base/autotest-deps-0.0.3"

# deps/fakegudev
RDEPEND="${RDEPEND}
	virtual/libgudev
"

# deps/fakemodem
RDEPEND="${RDEPEND}
	chromeos-base/autotest-fakemodem-conf
	dev-libs/dbus-glib
"
DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}
