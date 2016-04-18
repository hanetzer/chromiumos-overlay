# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="9a64c1ae522308819647503d654b4794c2abc76f"
CROS_WORKON_TREE="7306dad86fd29fcf2f8d52eaf51d781c188e96d8"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="glbench"

inherit cros-workon libchrome platform

DESCRIPTION="GLBench runs OpenGL or OpenGL ES performance tests"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="opengles"

RDEPEND="
	>=dev-cpp/gflags-2.0
	chromeos-base/libbrillo
	media-libs/libpng
	!opengles? ( virtual/opengl )
	opengles? ( virtual/opengles )
	x11-apps/xwd
"

DEPEND="
	${RDEPEND}
"

src_install() {
	dobin "${OUT}"/glbench
	dobin "${OUT}"/synccontroltest
	dobin "${OUT}"/teartest
	dobin "${OUT}"/windowmanagertest

	insinto /usr/share/glbench
	doins glbench_reference_images.txt
	doins glbench_knownbad_images.txt
	doins image.yuv
}
