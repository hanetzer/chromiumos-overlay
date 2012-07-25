# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=a8f7dd358bb67f69118a297bf5054363baaefaec
CROS_WORKON_TREE="8e56ed21ecaa9c5c4e0a6169a77df2c5b27daf9b"

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

