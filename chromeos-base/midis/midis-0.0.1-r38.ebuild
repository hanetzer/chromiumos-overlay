# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="dae99f9133a1c13fc2336bf8421426bc3869ba94"
CROS_WORKON_TREE="ce99d6d7b3d7eb4ce6f81d1988a282eda9e5a593"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="midis"

inherit cros-workon platform user

DESCRIPTION="MIDI Server for Chromium OS"
HOMEPAGE=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	dobin "${OUT}"/midis

	insinto /etc/init
	doins init/*.conf
}

pkg_preinst() {
	enewuser midis
	enewgroup midis
}
