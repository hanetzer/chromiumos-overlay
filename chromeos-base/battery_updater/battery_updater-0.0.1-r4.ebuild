# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="790f0977da667ef1e643d4c99b29624de03d9184"
CROS_WORKON_TREE="ba5048df1b911fa89ef0ada34c5bbcc4902ec401"
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
