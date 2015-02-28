# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="be64bd80e7e4d2311ecbe94b069183d07a02b07d"
CROS_WORKON_TREE="cd1976701aa47bd745bc4d514c6079787df312c9"
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
