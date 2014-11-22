# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="4652b8c6697fcec44f432b9e7ae11dd6cdfc35cd"
CROS_WORKON_TREE="36a3aff6c939848c77c2fe1162df4693f357b6b2"
CROS_WORKON_PROJECT="chromiumos/platform/drm-tests"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS DRM Tests"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="virtual/opengles"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC
	emake
}

src_install() {
	cd build-opt-local
	dobin null_platform_test
}
