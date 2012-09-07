# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="3d18208314ffd83b24d58d6358a284d16a0ce465"
CROS_WORKON_TREE="3c0bf7daa7d4aaf0725b0c838de2510b2ca0cb18"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

CONFLICT_LIST="chromeos-base/autotest-deps-0.0.1-r321"
inherit cros-workon autotest-deponly conflict cros-debug

DESCRIPTION="Autotest glbench dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Autotest enabled by default.
IUSE="+autotest"

LIBCHROME_VERS="125070"

RDEPEND="${RDEPEND}
	dev-cpp/gflags
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	virtual/opengl
	opengles? ( virtual/opengles )
	x11-apps/xwd
"

DEPEND="${RDEPEND}
	opengles? ( x11-drivers/opengles-headers )"

AUTOTEST_DEPS_LIST="glbench"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_prepare() {
	autotest-deponly_src_prepare
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}
}
