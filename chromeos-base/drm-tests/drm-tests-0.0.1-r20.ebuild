# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="299fab7486f520878f997e04330fa5f8572a12f0"
CROS_WORKON_TREE="6533aeff12c6264ae82241a522b724f219cfebb5"
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
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC
	emake
}

src_install() {
	cd build-opt-local
	dobin null_platform_test vgem_test vgem_fb_test swrast_test atomictest
}
