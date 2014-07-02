# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="5b4215a3a4b3e752c0e6e81cffc57d1e06efee57"
CROS_WORKON_TREE="f6c897fbfa435434ccce5643e3a6f9b9626827db"
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Touch firmware and config updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-touch-update.conf"

	exeinto "/opt/google/touch/scripts"
	doexe scripts/*.sh
}
