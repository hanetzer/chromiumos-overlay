# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4c3aa42a5220d08b9bc06fa15a494b9d25e83507"
CROS_WORKON_TREE="4cc8fe8cf3861ed455cb1c6f2cb3a09d81688576"
CROS_WORKON_PROJECT="chromiumos/platform/minigbm"
CROS_WORKON_LOCALNAME="../platform/minigbm"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit arc-build cros-workon

DESCRIPTION="ChromeOS gralloc implementation"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

VIDEO_CARDS="exynos intel marvell mediatek rockchip tegra"
IUSE="$(printf 'video_cards_%s ' ${VIDEO_CARDS})"

src_compile() {
	# Use arc-build base class to select the right compiler
	arc-build-select-gcc

	# The ARC sysroot only has prebuilt 32-bit libraries at this point
	if use amd64; then
		append-flags -m32
		append-ldflags -m32
	fi

	append-cppflags -I${ARC_SYSROOT}/usr/include/libdrm -D_LARGEFILE_SOURCE
	append-cppflags -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64

	# TODO(gsingh): use pkgconfig
	if use video_cards_intel; then
		export DRV_I915=1
		append-cppflags -DDRV_I915
		append-cppflags -I${ARC_SYSROOT}/usr/include/libdrm/intel
		append-libs drm_intel
	fi

	if use video_cards_rockchip; then
		export DRV_ROCKCHIP=1
		append-cppflags -DDRV_ROCKCHIP
		append-cppflags -I${ARC_SYSROOT}/usr/include/libdrm/rockchip
	fi

	if use video_cards_mediatek; then
		export DRV_MEDIATEK=1
		append-cppflags -DDRV_MEDIATEK
		append-cppflags -I${ARC_SYSROOT}/usr/include/libdrm/mediatek
	fi

	export TARGET_DIR="$(cros-workon_get_build_dir)/"
	cd "${S}/cros_gralloc/"
	emake
}

src_install() {
	exeinto "${ARC_PREFIX}/vendor/lib/hw/"
	doexe "${TARGET_DIR}"gralloc.cros.so
}
