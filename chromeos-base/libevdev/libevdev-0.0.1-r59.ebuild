# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="15ecd0cbe5ba833df9ec38bb40929ae0d9c1ef99"
CROS_WORKON_TREE="ad02b371027d341eb8cd1daff69df56d59fb20dc"
CROS_WORKON_PROJECT="chromiumos/platform/libevdev"
CROS_WORKON_USE_VCSID=1
CROS_WORKON_OUTOFTREE_BUILD=1

inherit toolchain-funcs multilib cros-debug cros-workon

DESCRIPTION="evdev userspace library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

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
	emake DESTDIR="${ED}" LIBDIR="/usr/$(get_libdir)" install
}
