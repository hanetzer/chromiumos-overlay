# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="bb2b55dc1da5976999e39e21b9563399d999e1fa"
CROS_WORKON_TREE="98a67afb7115c57e0fa5dc0c1913dfcc4ed7fc8e"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="arc-networkd"

inherit cros-workon libchrome platform

DESCRIPTION="ARC connectivity management daemon"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/libbrillo
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
