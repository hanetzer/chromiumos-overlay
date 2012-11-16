#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

EAPI=2
CROS_WORKON_COMMIT="55a9f7d329d3f398c81d16e7aa90337a67b13903"
CROS_WORKON_TREE="c3001346ef8b3c1d906887c6483a38b24acd104e"
CROS_WORKON_PROJECT="chromiumos/platform/punybench"
CROS_WORKON_LOCALNAME="../platform/punybench"
inherit toolchain-funcs cros-workon

DESCRIPTION="A set of file system microbenchmarks"
HOMEPAGE="http://git.chromium.org/gitweb/?s=punybench"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

##DEPEND="sys-libs/ncurses"

src_compile() {
	tc-export CC
	if [ "${ARCH}" == "amd64" ]; then
        PUNYARCH="x86_64"
	else
        PUNYARCH=${ARCH}
	fi
	emake BOARD="${PUNYARCH}"
}

src_install() {
	emake install BOARD="${PUNYARCH}" DESTDIR="${D}"
}
