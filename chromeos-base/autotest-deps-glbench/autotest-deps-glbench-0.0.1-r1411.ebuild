# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="dbe5a07733e8c5f7d1f399b558d06ef88224e0b4"
CROS_WORKON_TREE="51d62766e3964ebbbb9f9a5715eea7a88f3b3a65"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

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

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST="glbench"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/glbench
RDEPEND="${RDEPEND}
  dev-cpp/gflags
  chromeos-base/libchrome:85268[cros-debug=]
  virtual/opengl
  opengles? ( virtual/opengles )
  x11-apps/xwd
"

DEPEND="${RDEPEND}"

src_prepare() {
	autotest-deponly_src_prepare
	cros-debug-add-NDEBUG
}
