# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="1081bf6113b583bf5aafd1e42a2e59a7186ee18c"
CROS_WORKON_TREE="74536424447e082e008ca7aa1533c9386b631277"
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
