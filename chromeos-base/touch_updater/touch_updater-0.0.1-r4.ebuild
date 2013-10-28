# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="6a17c478462ba5ad1208f10e5ef13f444931d388"
CROS_WORKON_TREE="2490bce7fa829cc55258ed6487cd24efbf67c6f4"
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Touch firmware and config updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-touch-update.conf"

	exeinto "/opt/google/touch/scripts"
	doexe "scripts/chromeos-touch-config-update.sh"
	doexe "scripts/chromeos-touch-firmware-update.sh"
	doexe "scripts/chromeos-touch-common.sh"
}
