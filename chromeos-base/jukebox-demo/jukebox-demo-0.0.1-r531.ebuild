# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="e2a93f6bf3d838e43a0d1d7101855df21c11ed5e"
CROS_WORKON_TREE="6bb1c64c05a3d3e00b9377c4cbe169ee52914fa7"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="jukebox-demo"

inherit cros-workon libchrome platform

DESCRIPTION="Sample demo daemon for Brillo-based weave device"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
"

DEPEND="${RDEPEND}"

src_install() {
	# Main binary.
	dobin "${OUT}"/jukebox-demo

	# Weave command and state definitions.
	insinto /etc/buffet/commands
	doins etc/buffet/commands/*.json
	insinto /etc/buffet/states
	doins etc/buffet/states/*.json

	# Upstart script.
	insinto /etc/init
	doins etc/init/jukebox-demo.conf
}
