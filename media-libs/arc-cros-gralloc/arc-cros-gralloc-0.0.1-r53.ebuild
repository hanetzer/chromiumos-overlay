# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="cb1471bc69300f5203aa79b179a861c56c5c569f"
CROS_WORKON_TREE="c44e8951b64c6478d9a6853eeb75b9d8309739f1"
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

RDEPEND="
	x11-libs/arc-libdrm
"
DEPEND="${RDEPEND}"

src_compile() {
	# Use arc-build base class to select the right compiler
	arc-build-select-gcc

	# The ARC sysroot only has prebuilt 32-bit libraries at this point
	if use amd64; then
		append-flags -m32
		append-ldflags -m32
	fi

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

	export TARGET_DIR="$(cros-workon_get_build_dir)/"
	cd "${S}/cros_gralloc/"
	emake
}

src_install() {
	exeinto "${ARC_PREFIX}/vendor/lib/hw/"
	doexe "${TARGET_DIR}"gralloc.cros.so
}
