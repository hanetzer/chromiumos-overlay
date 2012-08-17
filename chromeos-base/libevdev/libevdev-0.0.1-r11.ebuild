# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=ec02884d13364bbd6a2ea596ca4b747a8f329024
CROS_WORKON_TREE="1dcc655c43ae6954bdedd7b09c075487611b05b7"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/libevdev"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs multilib cros-debug cros-workon

DESCRIPTION="evdev userspace library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_compile() {
	tc-export CC CXX
	cros-debug-add-NDEBUG
	emake
}

src_install() {
	emake DESTDIR="${ED}" LIBDIR="/usr/$(get_libdir)" install
}
