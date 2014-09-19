# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="eeac2ff6d3addc5a3a47062956ef9a067eca686e"
CROS_WORKON_TREE="02bd8d8afcbd44db55b93437d3197d282810779d"
CROS_WORKON_PROJECT="chromiumos/platform/minigbm"
CROS_WORKON_LOCALNAME="../platform/minigbm"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="Mini GBM implementation"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
VIDEO_CARDS="exynos intel rockchip tegra"
IUSE="-asan -clang"
for card in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${card}"
done
REQUIRED_USE="asan? ( clang )"

RDEPEND="x11-libs/libdrm"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	export LIBDIR="/usr/$(get_libdir)"
	use video_cards_exynos && append-cppflags -DGBM_EXYNOS
	use video_cards_intel && append-cppflags -DGBM_I915
	use video_cards_rockchip && append-cppflags -DGBM_ROCKCHIP
	use video_cards_tegra && append-cppflags -DGBM_TEGRA
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}
