# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="2afb71b61bc13c95470581b2ee578fd5e302d867"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chromium OS-specific assets"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
RDEPEND=""

CROS_WORKON_LOCALNAME="chromiumos-assets"
CROS_WORKON_PROJECT="chromiumos-assets"

src_install() {
	insinto /usr/share/chromeos-assets/images
	doins "${S}"/images/boot_splash.png
}
