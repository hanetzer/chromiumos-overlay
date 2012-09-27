# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8aa734a9e8f39c54ec221449fed6cf95c2c4b227"
CROS_WORKON_TREE="d5f6cc1967388d0c66ee1df614a29491fd93aa4d"

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
