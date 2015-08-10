# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1d09282203e15505323b01ef20c1592196f3d1d0"
CROS_WORKON_TREE="ac3cbbb1586914b8369b4e42273b7afa7cbcbd46"
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
