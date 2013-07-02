#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

EAPI=2
CROS_WORKON_COMMIT="4ebe9583f6022d9246e4d45b5003fb00c9fc84a0"
CROS_WORKON_TREE="53980df31813c5363fb7d6b7fd648ff0b6acfda1"
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

src_configure() {
	cros-workon_src_configure
}

src_install() {
	emake install BOARD="${PUNYARCH}" DESTDIR="${D}"
}
