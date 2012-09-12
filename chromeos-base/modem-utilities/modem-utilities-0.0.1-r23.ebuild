# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=8dda9f1fbf2d4383100cc328009885eef85541a3
CROS_WORKON_TREE="76cd2f640732d14cd30df2c604b4cb85932a34b3"

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
