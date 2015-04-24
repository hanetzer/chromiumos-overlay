# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="ba36346001835eed93ef33eba9a7fc80bb82976d"
CROS_WORKON_TREE="14721c48758f5db1c6c4a3cd7e34903d713d765a"
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
