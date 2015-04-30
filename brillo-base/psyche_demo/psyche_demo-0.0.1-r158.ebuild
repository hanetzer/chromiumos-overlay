# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="904eda66012c2cefbad129ae81eb54c37783841e"
CROS_WORKON_TREE="cc6b5f6d379a2c94dfa9ee15e6c07c421b9d2df4"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="psyche_demo"

inherit cros-workon platform

DESCRIPTION="Demonstration programs using psyche"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	brillo-base/libprotobinder
	brillo-base/libpsyche
	brillo-base/soma
	chromeos-base/libchromeos
	dev-libs/protobuf
"
DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/psyche_demo_{client,server}

	insinto /etc/container_specs
	doins com.android.embedded.*.json

}
