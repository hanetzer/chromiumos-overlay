# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a5c8057af10fbbec11f0ddcb5191fdea38cd7b5a"
CROS_WORKON_TREE="4aa738b61a16919197f91f6f4bb7e9a4e21d09c6"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform/audiotest"
inherit cros-workon

DESCRIPTION="Audio test tools"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="media-libs/alsa-lib
	media-sound/adhd
	sci-libs/fftw"
DEPEND="${RDEPEND}"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install

	# Install built tools
	pushd "${OUT}" >/dev/null
	dobin audiofuntest
	dobin test_tones
	dobin looptest
	dobin loopback_latency
	popd >/dev/null
}
