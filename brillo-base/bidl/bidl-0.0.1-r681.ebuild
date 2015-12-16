# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="738642524e671b860efe0c38adc6da4b923cb635"
CROS_WORKON_TREE="08e595399ee94ca4fa5061bd832a1ea6d1a70859"
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
