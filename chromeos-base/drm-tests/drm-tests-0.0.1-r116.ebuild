# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="fb2ddcf4acf95ff6b5b559d9548f483e5e91269d"
CROS_WORKON_TREE="9ba0d8b2af8390b1c0536c06e47093cafc9dc5fb"
CROS_WORKON_PROJECT="chromiumos/platform/drm-tests"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS DRM Tests"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="vulkan"

RDEPEND="virtual/opengles
	|| ( media-libs/mesa[gbm] media-libs/minigbm )
	vulkan? (
		media-libs/vulkan-loader
		virtual/vulkan-icd
	)"
DEPEND="${RDEPEND}
	x11-drivers/opengles-headers"

src_compile() {
	tc-export CC
	emake USE_VULKAN=$(usex vulkan 1 0)
}

src_install() {
	cd build-opt-local
	dobin atomictest drm_cursor_test gamma_test linear_bo_test \
	mapped_texture_test mmap_test null_platform_test plane_test \
	swrast_test vgem_test

	if use vulkan; then
		dobin vk_glow
	fi
}
