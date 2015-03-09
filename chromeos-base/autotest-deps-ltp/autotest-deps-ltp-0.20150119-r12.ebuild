# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="4290bd545748cae9e3abad8113dcf4f6dc82e840"
CROS_WORKON_TREE="3a0b9a46bfba61e07213a58a6decfe147fd29cb6"
CROS_WORKON_PROJECT="chromiumos/third_party/ltp"
CROS_WORKON_LOCALNAME=../third_party/ltp
CROS_WORKON_SUBDIR=

inherit cros-workon cros-constants

DESCRIPTION="Autotest kernel ltp dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST=""

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_prepare() {
	# Reset timetstamps since they might get out of sync with git.
	find utils/ffsb-6.0-rc2 -exec touch -r . {} + || die
	# Now rebuild autotools for dirs not checked in.
	emake autotools
}

src_configure() {
	cros-workon_src_configure \
		--prefix="${AUTOTEST_BASE}/client/deps/kernel_ltp_dep"
	# Used in make install
	export SKIP_IDCHECK=1
}
