# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2402056e9ba0612cc4d4e74ac2918dc68b3002b3"
CROS_WORKON_TREE="0cc43d89b5ac560bf5ca1c53d6ee4ceb0ebebe6f"
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
	dobin null_platform_test vgem_test vgem_fb_test swrast_test atomictest gamma_test plane_test drm_cursor_test linear_bo_test tiled_bo_test
}
