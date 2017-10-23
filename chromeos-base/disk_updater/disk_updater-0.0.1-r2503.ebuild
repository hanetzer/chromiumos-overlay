# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="cf3264f5823f2e6cfe12608a19ac88e205acac89"
CROS_WORKON_TREE="c9c1c127b85d5d33f31299563af22ac104aa65b2"
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
IUSE="mmc nvme"

DEPEND=""

RDEPEND="${DEPEND}
	chromeos-base/chromeos-installer
	sys-apps/hdparm
	mmc? ( sys-apps/mmc-utils )
	nvme? ( sys-apps/nvme-cli )"

platform_pkg_test() {
	# We can test all, even if mmc or nvme are not installed.
	local tests=( 'ata' 'mmc' 'nvme')

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
