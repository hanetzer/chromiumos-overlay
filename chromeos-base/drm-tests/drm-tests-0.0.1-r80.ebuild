# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="86d613f80bb895802822f8af35895ffa719f10f2"
CROS_WORKON_TREE="f646d27c0c1e8407a66db3e00a9d8bf89d262f10"
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
