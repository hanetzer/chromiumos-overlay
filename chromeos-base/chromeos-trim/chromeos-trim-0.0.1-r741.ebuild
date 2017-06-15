# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="01c3c6e8007f62df0d6371b71dacce1c035acb74"
CROS_WORKON_TREE="5f14f98881fda51a945c8d274d29159a7077a6fb"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="trim"

inherit cros-workon platform

DESCRIPTION="Stateful partition periodic trimmer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""

RDEPEND="${DEPEND}
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-init
	sys-apps/util-linux"

platform_pkg_test() {
	platform_test "run" "tests/chromeos-trim-test"
	platform_test "run" "tests/chromeos-do_trim-test"
}

src_install() {
	insinto "/etc/init"
	doins "init/trim.conf"

	insinto "/usr/share/cros"
	doins "share/trim_utils.sh"

	dosbin "scripts/chromeos-trim"
}
