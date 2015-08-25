# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="be3e2f61d4a5cc1c2e2d682a397fdbaf132da2bb"
CROS_WORKON_TREE="3b58b8287eb3fc851d2eeaabdd326dc12aabcd09"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="tpm2-simulator"

inherit cros-workon platform user

DESCRIPTION="TPM 2.0 Simulator"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-libs/openssl
	chromeos-base/tpm2
	chromeos-base/libchromeos
	"

DEPEND="
	${RDEPEND}
	"

src_install() {
	dobin "${OUT}"/tpm2-simulator
}
