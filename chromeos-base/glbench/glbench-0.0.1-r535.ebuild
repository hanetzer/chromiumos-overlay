# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="05e8cf6bf7f0af89ac28194d109a4791978875e4"
CROS_WORKON_TREE="34b8075a1f7c6de0bf06a32a32cf7bd374e266c8"
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
	chromeos-base/libchromeos
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
