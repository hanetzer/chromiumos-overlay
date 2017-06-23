# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="a444ac57597daac2afd1ea9c4e4c3838024d8896"
CROS_WORKON_TREE="3b4e2923a2cca22132710f1e9487bb9a9cc2c52e"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
PLATFORM_SUBDIR="vm_launcher"

inherit cros-workon platform

DESCRIPTION="Utility for launching a container in a VM"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
"
DEPEND="${RDEPEND}"

src_install() {
	cd "${OUT}"
	dobin vm_launcher
}
