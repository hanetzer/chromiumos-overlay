# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="42631b8bc6300b2f82cd2debad27889351a90452"
CROS_WORKON_TREE="f18c167021435b7acdf7a6e340b6529cdfbc1499"
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Touch firmware and config updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="input_devices_synaptics"

RDEPEND="
	input_devices_synaptics? ( chromeos-base/rmi4utils )
"
src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-touch-update.conf"

	exeinto "/opt/google/touch/scripts"
	doexe scripts/*.sh
}
