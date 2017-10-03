# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f7441d69280e4dc4fb4d7213afb77d71b074d944"
CROS_WORKON_TREE="1a4afcc24d379537077b0d7a420dbfe7b1272b18"
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
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libcab_test
}

src_install() {
	dobin common/libcab_test
	dolib common/libcam_algo.so
}
