# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=bf2e21f65ba1e665554f7cb917bb06fdef238ad2
CROS_WORKON_TREE="e2eb2e5afb174467d87fce73a147244ad1f6b062"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

CONFLICT_LIST="chromeos-base/autotest-deps-0.0.1-r321"
inherit cros-workon autotest-deponly conflict

DESCRIPTION="Autotest libaio dep"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST="libaio"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

DEPEND="${RDEPEND}"
