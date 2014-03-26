# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d5347d1035a795daf84f0cbdb6f192857a5b775c"
CROS_WORKON_TREE="5bff5439e8cd3468caa0dedf1f0ac3f5c4bf9258"
CROS_WORKON_PROJECT="chromiumos/platform/salsa"

inherit cros-workon toolchain-funcs

DESCRIPTION="Touchpad Experimentation Framework"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="242728"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}
	sys-libs/ncurses"
DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cd try_touch_experiment
	tc-export CXX PKG_CONFIG
	clang-setup-env
	export BASE_VER=${LIBCHROME_VERS}
	emake
}

src_install() {
	cd try_touch_experiment
	default
}
