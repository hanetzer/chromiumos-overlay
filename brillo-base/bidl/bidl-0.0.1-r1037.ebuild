# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="335627d48d046d47762738237595ff47bad4f1e3"
CROS_WORKON_TREE="f77b614ac4e63c80f8d56d1a4a57b95028c5ab59"
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
