# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="687f1cfebc73a4b878f76f4eaa411fa081a204fa"
CROS_WORKON_TREE="bb5b054526000b39bda973ec039ea2afa0963c06"
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
