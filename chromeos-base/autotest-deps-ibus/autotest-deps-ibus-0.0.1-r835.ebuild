# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="ebf3df32a3bfa32782ffdc8e0ce5bf6d65734d5d"
CROS_WORKON_TREE="52b16487b68a08e2ae60aa1426baca1a0231adc4"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest ibusclient deps"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST="ibusclient"
AUTOTEST_CONFIG_LIST=
AUTOTEST_PROFILERS_LIST=

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/ibusclient
RDEPEND="
	app-i18n/ibus
	dev-libs/glib
	sys-apps/dbus
"

DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}


