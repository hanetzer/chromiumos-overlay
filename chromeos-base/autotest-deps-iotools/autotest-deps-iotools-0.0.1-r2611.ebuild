# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="6e9817fa92eb4b349e7ca0d6e199bc7cb1be5305"
CROS_WORKON_TREE="0c3267dd3b07c51e222d73fe5cefc1e79f7a6e7e"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

CONFLICT_LIST="chromeos-base/autotest-deps-0.0.1-r321"
inherit cros-workon autotest-deponly conflict

DESCRIPTION="Autotest iotools dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST="iotools"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

DEPEND="${RDEPEND}"

