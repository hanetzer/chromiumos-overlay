# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="64bde2fb1616924d632e4772d1e95acf9ecccf04"
CROS_WORKON_TREE="1a3a6e04e866335ac9ef2bd9b13d5df5d5669248"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest chromium ffmpeg dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST="ffmpeg"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/ffmpeg
RDEPEND="${RDEPEND}
	chromeos-base/chromeos-chrome
"

DEPEND="${RDEPEND}"

