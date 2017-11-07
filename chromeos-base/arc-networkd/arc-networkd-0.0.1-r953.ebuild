# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="334454ec868fa8f1a349bb3a049ba7d3e58f27fd"
CROS_WORKON_TREE="d1c25bed10581b038d50d5ecb9f18e130d342d95"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="arc-networkd"

inherit cros-workon libchrome platform user

DESCRIPTION="ARC connectivity management daemon"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/libbrillo
	dev-libs/protobuf
	net-libs/libndp
"

RDEPEND="${COMMON_DEPEND}"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/shill-client
	chromeos-base/system_api
"

src_install() {
	# Main binary.
	dobin "${OUT}"/arc-networkd
}

pkg_preinst() {
	# Service account used for privilege separation.
	enewuser arc-networkd
	enewgroup arc-networkd
}
