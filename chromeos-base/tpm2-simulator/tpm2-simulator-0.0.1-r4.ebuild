# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="c2cd0b54bdb2022df50b9a70c55346fa17c3decf"
CROS_WORKON_TREE="f116b60d42a2d47c11e784d5d806be282a82e32b"
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
