#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

EAPI=4
CROS_WORKON_COMMIT="52d09bd25a02b3866aba1bb492f36a2d851d6472"
CROS_WORKON_TREE="235f592178311af797b3230503069777982fdc3d"
CROS_WORKON_PROJECT="chromiumos/third_party/ktop"

inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="Utility for looking at top users of system calls"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

DEPEND="sys-libs/ncurses"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	tc-export CC
}
