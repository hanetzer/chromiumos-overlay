# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1f120022431d7427f91974b99a7de66d3f2f9783"
CROS_WORKON_TREE="7447caea50e9b1647d535ce911443c00091f9b55"
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
