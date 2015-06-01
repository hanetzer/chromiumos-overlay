# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="da28ccfff1375d30a08188e9421e690c1beb101b"
CROS_WORKON_TREE="44c587fe2f3ff05ec4891fe27f434a2062f48c6d"
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
	sys-fs/udev[gudev]
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
