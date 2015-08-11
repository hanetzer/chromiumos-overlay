# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="2d0870476357df22a81109512c0e8c3d5ecacfa6"
CROS_WORKON_TREE="f0011e70fc738f32194729b4fb4581057b6d15cb"
CROS_WORKON_PROJECT="chromiumos/third_party/tpm2"
CROS_WORKON_LOCALNAME="../third_party/tpm2"

inherit cros-workon

DESCRIPTION="TPM2.0 library"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-libs/openssl"

src_compile() {
	if [ "${ARCH}" == "arm" ]; then
		export CROSS_COMPILE=arm-none-eabi-
	fi
	emake
}

src_install() {
	dolib.a build/libtpm2.a
}
