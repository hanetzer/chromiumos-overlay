# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cmake-utils

DESCRIPTION="Vulkan Loader and Validation Layers"
HOMEPAGE="https://www.khronos.org/vulkan"
SRC_URI="https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers/archive/sdk-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Vulkan-LoaderAndValidationLayers-sdk-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

# (chadversary): The tarball's BUILD.md file lists build deps only if building
# WSI support. The ebuild has no deps because it disables all WSI support.
RDEPEND=""
DEPEND="${RDEPEND}"

src_configure() {
	# The tarball provides much stuff we don't care about on Chromium OS.
	# All we currently want is the ICD loader.
	local mycmakeargs=(
		-DBUILD_LOADER=1
		-DBUILD_LAYERS=0
		-DBUILD_DEMOS=0
		-DBUILD_VKJSON=0
		-DBUILD_TESTS=0
		-DBUILD_WSI_WAYLAND_SUPPORT=0
		-DBUILD_WSI_XCB_SUPPORT=0
		-DBUILD_WSI_XLIB_SUPPORT=0
	)

	cmake-utils_src_configure
}

src_install() {
	dolib "${BUILD_DIR}"/loader/libvulkan.*
}
