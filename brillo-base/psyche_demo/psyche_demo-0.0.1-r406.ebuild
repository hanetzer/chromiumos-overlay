# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="27ff6ae8940a3d1b7362e4471d09d51e578d3bdf"
CROS_WORKON_TREE="c5af2a0c4b8a8ba9dcb815712259fe908b239b5a"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="psyche_demo"

inherit cros-workon platform brillo-sandbox

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

	# TODO(cmasone) Remove JSON appc manifests from disk when somad no
	#               longer makes use of them.
	insinto /etc/container_specs
	doins com.android.embedded.*.json
	dobrsandbox com.android.embedded.demo-brick.json
}
