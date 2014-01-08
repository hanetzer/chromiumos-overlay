# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="81443d1220cdd975554b04518bf1c15d058179c8"
CROS_WORKON_TREE="b35fdc62a45cbf00c3fd6206748fef586ebb734e"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest glmark2 dependency"
HOMEPAGE="https://launchpad.net/glmark2"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

# Autotest enabled by default.
IUSE="-asan +autotest -clang opengles"
REQUIRED_USE="asan? ( clang )"

AUTOTEST_DEPS_LIST="glmark2"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# Note: USE="opengles" sets graphics_backend=OPENGLES in autotest.eclass.
# This causes client/deps/glmark2/glmark2.py to build glmark2-es which
# RDEPENDS=virtual/opengles.
# Alternatively, USE="-opengles" builds glmark2, which RDEPENDS=virtual/opengl

# deps/glmark2
RDEPEND="
	opengles? ( virtual/opengles )
	!opengles? ( virtual/opengl )
	media-libs/libpng
	sys-libs/zlib
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libXext
"

DEPEND="${RDEPEND}"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}


