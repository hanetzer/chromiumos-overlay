# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="bae7b068503bb7eb203ca6ab3522b68c42498f21"
CROS_WORKON_TREE="47f2941c730c3438991e33c59110f77ff2ccd7ed"
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
	chromeos-base/libchrome
	chromeos-base/libchromeos
	dev-libs/protobuf
"
DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/psyche_demo_{client,server}
}
