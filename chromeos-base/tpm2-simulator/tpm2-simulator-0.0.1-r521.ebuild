# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="830ed55648c201e6ee8abb01e57dca9fbc4591f3"
CROS_WORKON_TREE="63f629c6c5909a77d83daeb10ba60443a979924a"
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
	chromeos-base/libbrillo
	"

DEPEND="
	chromeos-base/tpm2
	${RDEPEND}
	"

src_install() {
	dobin "${OUT}"/tpm2-simulator
}
