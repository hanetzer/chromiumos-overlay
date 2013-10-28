#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

EAPI=2
CROS_WORKON_COMMIT="9b0b97771af89c9e5bcdd985284a08929e7a2b92"
CROS_WORKON_TREE="80d059f521db86b448263933209d22a481be6272"
CROS_WORKON_PROJECT="chromiumos/platform/punybench"
CROS_WORKON_LOCALNAME="../platform/punybench"
inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="A set of file system microbenchmarks"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
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
