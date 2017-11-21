# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f0361ec82359094d585a01d45a35804528892b1f"
CROS_WORKON_TREE="1a8b990827c2d67da07d744756c21ecc563c6bce"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Test for camera algorithm bridge library"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	media-libs/arc-camera3-libcab"

DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libcab_test
}

src_install() {
	dobin common/libcab_test
	dolib common/libcam_algo.so
}
