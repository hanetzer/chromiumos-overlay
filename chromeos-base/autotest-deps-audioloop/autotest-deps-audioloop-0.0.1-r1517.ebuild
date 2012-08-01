# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="b207e9baf4cd8640d670f09ddde0971a6ced5b96"
CROS_WORKON_TREE="877cb27d13bb46fa9ed88742c8fad65293f12b88"

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

