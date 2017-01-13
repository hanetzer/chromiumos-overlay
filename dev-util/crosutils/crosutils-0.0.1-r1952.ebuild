# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="2e722a283cdc2dc8d0e212c7df2c2631ee335bfb"
CROS_WORKON_TREE="97be0eeae1a5419ae0979bd37b529058d5953d7a"
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
