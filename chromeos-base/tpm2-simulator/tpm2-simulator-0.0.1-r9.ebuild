# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="690829e8db84e15e70b52dee82117f5c807e6641"
CROS_WORKON_TREE="d3ebdc922b765427d02fd2f8fbfe19e500d857e9"
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
