# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="ffcb2b1c3e4a1ad72910d97f08639742e0ad3b4f"
CROS_WORKON_TREE="be502d944ead0dd2be27dcc4426c5050a488f0e3"
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
