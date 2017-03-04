# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="59ff9f9b438ba1350dfaeea438bc4a34a4bbe190"
CROS_WORKON_TREE="58ac66f36184fabb7a39f15a143668ab01d5d8dc"
CROS_WORKON_PROJECT="chromiumos/platform/drm-tests"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS DRM Tests"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="virtual/opengles
	|| ( media-libs/mesa[gbm] media-libs/minigbm )"
DEPEND="${RDEPEND}
	x11-drivers/opengles-headers"

src_compile() {
	tc-export CC
	emake
}

src_install() {
	cd build-opt-local
	dobin atomictest drm_cursor_test gamma_test linear_bo_test mmap_test
	dobin null_platform_test plane_test swrast_test tiled_bo_test vgem_test
}
