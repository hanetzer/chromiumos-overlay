# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="33cca93af658650b655b4b5dcfb18a3235a100cf"
CROS_WORKON_TREE="43c6505bd9113afa6c631eac273755c1a7a36a96"
CROS_WORKON_PROJECT="chromiumos/platform/minigbm"
CROS_WORKON_LOCALNAME="../platform/minigbm"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit multilib-minimal arc-build cros-workon

DESCRIPTION="ChromeOS gralloc implementation"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

VIDEO_CARDS="exynos intel marvell mediatek rockchip tegra"
IUSE="$(printf 'video_cards_%s ' ${VIDEO_CARDS})"

RDEPEND="
	x11-libs/arc-libdrm[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"

src_configure() {
	# Use arc-build base class to select the right compiler
	arc-build-select-gcc

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

	multilib-minimal_src_configure
}

multilib_src_compile() {
	export TARGET_DIR="${BUILD_DIR}/"
	cd "${S}/cros_gralloc/"
	emake
}

multilib_src_install() {
	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/hw/"
	doexe "${BUILD_DIR}"/gralloc.cros.so
}
