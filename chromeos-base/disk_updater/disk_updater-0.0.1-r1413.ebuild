# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1b528df4680a6d718d858bbc8c78a49a38e69c97"
CROS_WORKON_TREE="61a33e4a624020c81b6db2792b061c3a9442b194"
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
