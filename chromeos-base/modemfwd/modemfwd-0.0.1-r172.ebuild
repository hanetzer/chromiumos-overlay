# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="962803e88382971381a7223998389f4b040e4d19"
CROS_WORKON_TREE="e278b014f08ac8b3272b77cd0cd98e39923a5e9b"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="modemfwd"

inherit cros-workon platform user

DESCRIPTION="Modem firmware updater daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/modemfwd"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
	dev-libs/protobuf
"

DEPEND="${RDEPEND}
	chromeos-base/shill-client
	chromeos-base/system_api
"

src_install() {
	dobin "${OUT}/modemfwd"
}

pkg_preinst() {
	enewuser "modem-updater"
	enewgroup "modem-updater"
}

platform_pkg_test() {
	platform_test "run" "${OUT}/modemfw_unittest"
}
