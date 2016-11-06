# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="18f0df178e5251691a96ca681856a957c8599605"
CROS_WORKON_TREE="793a14d72b441bf75d8d85fd8dd303f3a32660f6"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="bidl"

inherit cros-workon platform

DESCRIPTION="Protobuf plugin for generating Brillo RPC"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/protobuf"


src_install() {
	dobin "${OUT}/protoc-gen-bidl"
}
