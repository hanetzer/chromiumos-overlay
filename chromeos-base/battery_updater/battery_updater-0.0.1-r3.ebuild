# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3cf0cae44198b2a9c26a877139bafeaaa9e1eff2"
CROS_WORKON_TREE="a9fea9175b62501d80bdf4c3d911983b8ffab8a8"
CROS_WORKON_PROJECT="chromiumos/platform/battery_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Battery Firmware Updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-battery-update.conf"

	exeinto "/opt/google/battery/scripts"
	doexe scripts/*.sh
}
