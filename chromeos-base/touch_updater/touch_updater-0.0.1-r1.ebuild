# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1091247e3a8c10001253275b1f81ccbfdf02d73e"
CROS_WORKON_TREE="32a5d047ec48263bef00de7c9d2c28c76eb98343"
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Touch firmware and config updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-touch-update.conf"

	exeinto "/opt/google/touch/scripts"
	doexe "scripts/chromeos-touch-config-update.sh"
	doexe "scripts/chromeos-touch-firmware-update.sh"
	doexe "scripts/chromeos-touch-common.sh"
}
