# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="2eeaf5a03c9ad55b27ced2800b5a5ac97531604c"
CROS_WORKON_TREE="f95b5f9c14f7f34ee1c565298f55623c48bad819"
CROS_WORKON_PROJECT="chromiumos/platform/minigbm"
CROS_WORKON_LOCALNAME="../platform/minigbm"

inherit multilib-minimal arc-build cros-workon

DESCRIPTION="ChromeOS gralloc implementation"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

VIDEO_CARDS="amdgpu exynos intel marvell mediatek rockchip tegra virgl"
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
		append-cppflags -DDRV_AMDGPU -DHAVE_LIBDRM
	fi

	if use video_cards_virgl; then
		export DRV_VIRGL=1
		append-cppflags -DDRV_VIRGL
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
