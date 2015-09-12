# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="e6bebd36a8cb0db343d0895a3f6508aa2638f343"
CROS_WORKON_TREE="b9e418e7d7d77a0e2dcc9274bf22f119b2580de7"
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
