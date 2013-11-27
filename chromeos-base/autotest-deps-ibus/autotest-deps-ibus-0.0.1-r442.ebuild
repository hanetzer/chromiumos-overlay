# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="605f764c1b6c48427f2938458ee381719a164017"
CROS_WORKON_TREE="f3907bace7a0d590e3804c6fa205906b8cc5861f"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest ibusclient deps"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

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


