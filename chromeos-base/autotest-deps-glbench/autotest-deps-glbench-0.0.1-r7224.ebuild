# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="118a009d5db55e49f8beb17015a64efe04078e06"
CROS_WORKON_TREE="f700d9e22e0d7faa3bc8401e2ca9ede47ce19a15"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest-deponly cros-debug libchrome

DESCRIPTION="Autotest glbench dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest X"

RDEPEND="${RDEPEND}
	>=dev-cpp/gflags-2.0
	media-libs/libpng
	!opengles? ( virtual/opengl )
	opengles? ( virtual/opengles )
	media-libs/waffle
"

DEPEND="${RDEPEND}"

AUTOTEST_DEPS_LIST="glbench"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_prepare() {
	autotest-deponly_src_prepare
	cros-debug-add-NDEBUG
}

src_configure() {
	cros-workon_src_configure
}
