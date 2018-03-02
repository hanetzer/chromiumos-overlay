# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="23e006a90b51589a7515a66777477398ee20c576"
CROS_WORKON_TREE="5d45eed9eeea0aa4dcbfa2aad3ecddb70f1347de"
CROS_WORKON_PROJECT="chromiumos/platform/minigbm"
CROS_WORKON_LOCALNAME="../platform/minigbm"

inherit multilib-minimal arc-build cros-workon

DESCRIPTION="ChromeOS gralloc implementation"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

VIDEO_CARDS="amdgpu exynos intel marvell mediatek rockchip tegra"
IUSE="$(printf 'video_cards_%s ' ${VIDEO_CARDS})"

RDEPEND="
	x11-libs/arc-libdrm[${MULTILIB_USEDEP}]
	video_cards_amdgpu? ( media-libs/arc-amdgpu-addrlib )
"
DEPEND="${RDEPEND}"

src_configure() {
	# Use arc-build base class to select the right compiler
	arc-build-select-clang

	BUILD_DIR="$(cros-workon_get_build_dir)"

	append-lfs-flags

	# TODO(gsingh): use pkgconfig
	if use video_cards_intel; then
		export DRV_I915=1
		append-cppflags -DDRV_I915
	fi

	if use video_cards_rockchip; then
		export DRV_ROCKCHIP=1
		append-cppflags -DDRV_ROCKCHIP
	fi

	if use video_cards_mediatek; then
		export DRV_MEDIATEK=1
		append-cppflags -DDRV_MEDIATEK
	fi

	if use video_cards_amdgpu; then
		export DRV_AMDGPU=1
		append-cppflags -DDRV_AMDGPU
	fi

	multilib-minimal_src_configure
}

multilib_src_compile() {
	export TARGET_DIR="${BUILD_DIR}/"
	emake -C "${S}/cros_gralloc"
	emake -C "${S}/cros_gralloc/gralloc0/tests/"
}

multilib_src_install() {
	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/hw/"
	doexe "${BUILD_DIR}"/gralloc.cros.so
	into "/usr/local/"
	newbin "${BUILD_DIR}"/gralloctest "gralloctest_${ABI}"
}
