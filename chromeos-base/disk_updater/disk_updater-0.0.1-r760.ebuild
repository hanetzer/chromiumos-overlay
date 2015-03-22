# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="384bc55ddfe9bfa3666b0bda26e9adf47569c336"
CROS_WORKON_TREE="3da093d90e4e4c652ab4b33a8c64dfc55100df64"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="disk_updater"

inherit cros-workon platform

DESCRIPTION="Root disk firmware updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""

RDEPEND="${DEPEND}
	chromeos-base/chromeos-installer
	sys-apps/hdparm
	sys-apps/mmc-utils"

platform_pkg_test() {
	local tests=( 'ata' 'mmc' )

	local test_type
	for test_type in "${tests[@]}"; do
		platform_test "run" "tests/chromeos-disk-firmware-${test_type}-test.sh"
	done
}

src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-disk-firmware-update.conf"

	dosbin "scripts/chromeos-disk-firmware-update.sh"
}
