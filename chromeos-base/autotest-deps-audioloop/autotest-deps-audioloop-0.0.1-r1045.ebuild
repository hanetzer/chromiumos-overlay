# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="c67889114a83e3bf9e892b774a1ffedf0d07df32"
CROS_WORKON_TREE="5ef5eba64f120347e6a56f46e00402a41c32e10f"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest audioloop dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST="audioloop"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/audioloop
RDEPEND="${RDEPEND}
	media-libs/alsa-lib"

DEPEND="${RDEPEND}"

