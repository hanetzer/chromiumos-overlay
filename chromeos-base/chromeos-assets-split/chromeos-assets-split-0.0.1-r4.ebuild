# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="55b5d94d9aa2fa6853ad58b2c78fcb43c5cf789f"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chromium OS-specific assets"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

PDEPEND=">chromeos-base/chromeos-assets-0.0.1-r47"
DEPEND=""
RDEPEND=""

CROS_WORKON_LOCALNAME="chromiumos-assets"
CROS_WORKON_PROJECT="chromiumos-assets"

src_install() {
	insinto /usr/share/chromeos-assets/images
	doins "${S}"/images/boot_splash.png

  insinto /usr/share/chromeos-assets/screensavers
  doins -r "${S}"/screensavers/*
}
