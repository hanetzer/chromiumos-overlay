# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="54532f2b9ec7f8fad03e8eccec718d0670893f62"
CROS_WORKON_TREE="37bfe4eebe4d5cb1b99c6704b91600c1bcac4fbf"
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
