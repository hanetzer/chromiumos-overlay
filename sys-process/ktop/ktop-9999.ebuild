#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/ktop"

inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="Utility for looking at top users of system calls"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

DEPEND="sys-libs/ncurses"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	tc-export CC
}
