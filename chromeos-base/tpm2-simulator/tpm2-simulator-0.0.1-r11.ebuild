# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="eb145567b1f81878bc2bc37d9fea29691404f058"
CROS_WORKON_TREE="2dac01a65c9f3c40d0e3ad473ece6e81da6303a3"
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
