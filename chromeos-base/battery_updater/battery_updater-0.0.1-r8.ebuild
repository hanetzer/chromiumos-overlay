# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ac36f581e334a491bd2700a9caf2a2e4c6d7e23e"
CROS_WORKON_TREE="6acd08b6cb0b6f3e3ecf6e1f1859bdc39a9acf9a"
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
	doexe scripts/chromeos-battery-update.sh
}
