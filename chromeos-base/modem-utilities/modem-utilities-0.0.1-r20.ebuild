# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8080b5b84ae899201a6620396b23191e28013948"
CROS_WORKON_TREE="42199716d28a0311de8204b4f21e9b318165b0ba"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/modem-utilities"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chromium OS modem utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND="
	sys-apps/dbus
"

DEPEND="${RDEPEND}"

src_compile() {
	cros-debug-add-NDEBUG
	emake || die "Failed to compile"
}

src_install() {
	emake DESTDIR=${D} install || die "Install failed"
}
