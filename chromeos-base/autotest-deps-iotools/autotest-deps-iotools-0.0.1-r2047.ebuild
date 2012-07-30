# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=a7f11ab8b5f9c65b48666595706e8f227d92805e
CROS_WORKON_TREE="a36c0f5d84d9b00d406e475c2153d82fb7f59dd9"

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

