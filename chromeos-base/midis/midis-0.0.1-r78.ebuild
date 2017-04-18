# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="b0a9b6df810b26071335b3dab1640577cdbd1b3a"
CROS_WORKON_TREE="82b54c965ac81f426643681c3a5785ac03bee8de"
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

platform_pkg_test() {
	platform_test "run" "${OUT}"/device_tracker_test
	platform_test "run" "${OUT}"/udev_handler_test
}
