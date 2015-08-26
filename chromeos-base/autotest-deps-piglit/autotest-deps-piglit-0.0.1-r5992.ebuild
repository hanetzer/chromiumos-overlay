# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9476b04fb0a8422ef3c83f89523359d5e6f46745"
CROS_WORKON_TREE="99cc87447c9f512dc428cbefaa650c609a2e1e5d"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest-deponly

DESCRIPTION="dependencies for Piglit (collection of automated tests for OpenGl based on glean and mesa)"
HOMEPAGE="http://cgit.freedesktop.org/piglit"
SRC_URI=""
LICENSE="GPL-2 LGPL-3"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest opengl"

AUTOTEST_DEPS_LIST="piglit"
RDEPEND="
	opengl? ( virtual/glut )
	opengl? ( virtual/opengl )
	dev-python/mako
	dev-python/numpy
	media-libs/tiff
	media-libs/libpng
	sys-libs/zlib
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXtst
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXpm
	x11-libs/libXrender
	opengl? ( x11-proto/glproto )
	"
# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

DEPEND="${RDEPEND}"

# export a variable so that piglit knows where to find libglut.so
export GLUT_LIBDIR=/usr/$(get_libdir)

src_configure() {
	cros-workon_src_configure
}
