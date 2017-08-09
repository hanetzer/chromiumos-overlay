# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="04818be4cc8d1cb224bac95d67afd552ff4e6d3f"
CROS_WORKON_TREE="84494fde7600952ad2617d3d60b43f67a9f2f250"
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
