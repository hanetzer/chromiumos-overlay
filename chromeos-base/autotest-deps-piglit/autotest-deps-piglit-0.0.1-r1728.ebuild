# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="35a8a3f744b5183b7c07bbc58c2129cfd89aea8b"
CROS_WORKON_TREE="8a5e7eaa5e3cbe9346fa3c2637ece99c9e0f7348"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"


inherit cros-workon autotest-deponly

DESCRIPTION="dependencies for Piglit (collection of automated tests for OpenGl based on glean and mesa)"
HOMEPAGE="http://cgit.freedesktop.org/piglit"
SRC_URI=""
LICENSE="GPL"
SLOT="0"
KEYWORDS="amd64 arm x86"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST="piglit"
RDEPEND="
	virtual/glut
	virtual/opengl
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
	"
# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

DEPEND="${RDEPEND}"

# export a variable so that piglit knows where to find libglut.so
export GLUT_LIBDIR=/usr/$(get_libdir)
