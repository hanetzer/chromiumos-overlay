# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="21ece3ace803f98c50556c1f2d59d29cfbd0e15e"
CROS_WORKON_TREE="d72256d15bdcad8de8a2b4a28c3c461d74874ba7"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="bluetooth"

inherit cros-workon platform

DESCRIPTION="Bluetooth service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/bluetooth"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	chromeos-base/system_api"

src_install() {
	dobin "${OUT}"/newblued

	insinto /etc/init
	doins init/upstart/newblued.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/newblued_test"
}
