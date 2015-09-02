# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="b39658bd566a7b3c6f5b647d1d56fd51bc1aa03e"
CROS_WORKON_TREE="28af1e533de20e3b46befb252238a3d001d8d492"
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
