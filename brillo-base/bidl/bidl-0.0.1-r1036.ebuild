# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="232c5333a23c51723557abb234ad1a658d0d80af"
CROS_WORKON_TREE="511018db49e74df683fb1c9afc5a61781e363dfe"
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
