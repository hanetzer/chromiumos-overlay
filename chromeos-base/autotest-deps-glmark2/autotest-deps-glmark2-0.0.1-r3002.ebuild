# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="188e636ab1f1267f88246f8a5e8c8cc625140263"
CROS_WORKON_TREE="d71f17c14a26fedb3ec1934eee1ad230d2e58429"
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


