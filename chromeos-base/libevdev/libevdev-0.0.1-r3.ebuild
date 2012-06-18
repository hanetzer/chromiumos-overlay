# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="107779ad9e3917c9a7e096abb4e8071694469033"
CROS_WORKON_TREE="6938cd4ec5305e111a0f5cf597f14f6ae3b68e6d"

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
