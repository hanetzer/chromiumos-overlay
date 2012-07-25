# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8b2fa0aa498bd1d4d577647dd3330c3b0619ae13"
CROS_WORKON_TREE="a83f8f48b3d963dede174b96ffb8c7e6220df8e2"

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
