# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="7a425a3ebff071ea12a9c9daf318e6b7d4c5e6ff"
CROS_WORKON_TREE="93787108afe686f8e3ed07a4b3639c6ac3635fb6"
CROS_WORKON_PROJECT="chromiumos/third_party/ltp"
CROS_WORKON_LOCALNAME=../third_party/ltp
CROS_WORKON_SUBDIR=

CONFLICT_LIST="chromeos-base/autotest-tests-ltp-0.0.1-r2064"
inherit cros-workon conflict

DESCRIPTION="Autotest kernel ltp dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST=""

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_prepare() {
	emake autotools
}

src_configure() {
	econf --prefix="/usr/local/autotest/client/deps/kernel_ltp_dep"
	# Used in make install
	export SKIP_IDCHECK=1
}
