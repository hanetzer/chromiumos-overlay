# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=d57e84f44100fe4895354a4f63329c7f2e8de586
CROS_WORKON_TREE="cdcde07c9d826b3812fc23bc7fccccf08035d05b"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/chromiumos-assets"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chromium OS-specific assets"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

PDEPEND=">chromeos-base/chromeos-assets-0.0.1-r47"
DEPEND=""
RDEPEND=""

CROS_WORKON_LOCALNAME="chromiumos-assets"

src_install() {
	insinto /usr/share/chromeos-assets/images
	doins -r "${S}"/images/*

	insinto /usr/share/chromeos-assets/images_100_percent
	doins -r "${S}"/images_100_percent/*

	insinto /usr/share/chromeos-assets/images_200_percent
	doins -r "${S}"/images_200_percent/*

	insinto /usr/share/chromeos-assets/screensavers
	doins -r "${S}"/screensavers/*
}
