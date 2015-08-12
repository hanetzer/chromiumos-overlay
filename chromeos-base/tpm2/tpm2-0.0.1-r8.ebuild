# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="8931d21cdb99bc3a6ce4833bf384a94349470a4d"
CROS_WORKON_TREE="8025c8341fdf9cd4b9de27948900328d6513dc13"
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
