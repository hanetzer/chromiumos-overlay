# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="00422f530741cb52750b76d7c2b3682cbd8644c5"
inherit cros-workon toolchain-funcs

DESCRIPTION="Audio configuration files."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

CROS_WORKON_PROJECT="audioconfig"
CROS_WORKON_LOCALNAME="${CROS_WORKON_PROJECT}"

src_install() {
	dodir /etc
	insinto /etc
	doins "${S}"/asound.conf

	dodir /etc/pulse
	insinto /etc/pulse
	doins "${S}"/pulse/*
}
