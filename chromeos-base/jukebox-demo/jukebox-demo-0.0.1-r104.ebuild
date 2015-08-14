# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="50fb55a05efdd0b31dc8dcbb53591bfff68f8703"
CROS_WORKON_TREE="e728932e855845eb6ec2243a762d3e3c72ca1b91"
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
	chromeos-base/libchromeos
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
