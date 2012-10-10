#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#
CROS_WORKON_COMMIT=e1ef188aef7dc7334f06fa65709435623e059919
CROS_WORKON_TREE="de7ac6bd5c6bbf8d2b8fff7c28ae5abd5f22cd8f"

EAPI=2
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
