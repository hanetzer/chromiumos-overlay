# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ea1f3c7f320e6b7d54358c0692d6e35511e36056"
CROS_WORKON_TREE="722bbb715ca8044c45acd618ad3284c98addf569"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest common deps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

# following deps don't compile: boottool, mysql, pgpool, pgsql, systemtap, # dejagnu, libcap, libnet
# following deps are not deps: factory
# following tests are going to be moved: chrome_test
AUTOTEST_DEPS_LIST="gtest iwcap realtimecomm_playground pyxinput example_cros_dep"
AUTOTEST_CONFIG_LIST=*
AUTOTEST_PROFILERS_LIST=*

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/gtest
RDEPEND="
	dev-cpp/gtest
"

# deps/iwcap
RDEPEND="${RDEPEND}
	dev-libs/libnl:0
"

# FAFT deps
RDEPEND="${RDEPEND}
	sys-apps/hdparm
	sys-apps/mmc-utils
"

RDEPEND="${RDEPEND}
	sys-devel/binutils
"
DEPEND="${RDEPEND}"

src_prepare() {
	autotest-deponly_src_prepare

	# To avoid a file collision with autotest.ebuild, remove
	# one particular __init__.py file from working directory.
	# See crbug.com/324963 for context.
	rm "${AUTOTEST_WORKDIR}/client/profilers/__init__.py"
}
