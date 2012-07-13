# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="02668179974d04f788219f800c64ca0018eb90f2"
CROS_WORKON_TREE="d4bb7c7677e9ddb2bb8abee05ce71d2959c69645"

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
