# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="d024847f5af032699bab466e3e396f52f3ceff68"
CROS_WORKON_TREE="96fc682335776096ff1b507900dffd9d7436de74"

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
