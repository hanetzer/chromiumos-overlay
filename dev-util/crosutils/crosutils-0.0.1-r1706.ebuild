# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="951cfb25388262d456e390636d94dbbdb470af80"
CROS_WORKON_TREE="5a6657b34849b3fedc7973a6c60b6b58f6c8be8e"
CROS_WORKON_PROJECT="chromiumos/platform/crosutils"
CROS_WORKON_LOCALNAME="../scripts/"

inherit cros-workon

DESCRIPTION="Chromium OS build utilities"
HOMEPAGE="http://www.chromium.org/chromium-os"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_unpack() {
	cros-workon_src_unpack

	# Clean out files we don't use.
	cd "${S}"
	find -type l -delete
	rm -rf PRESUBMIT.cfg WATCHLISTS inherit-review-settings-ok lib/shflags
}

src_install() {
	exeinto /usr/lib/crosutils
	doexe *

	insinto /usr/lib/crosutils/lib
	doins lib/*
}
