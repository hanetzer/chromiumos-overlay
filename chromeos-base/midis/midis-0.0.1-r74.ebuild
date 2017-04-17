# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="620b9d88f1c73ecc294ec06692875c569ce62f47"
CROS_WORKON_TREE="c6f78ff956040915bec3fe8c0d33c5d28371e943"
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
