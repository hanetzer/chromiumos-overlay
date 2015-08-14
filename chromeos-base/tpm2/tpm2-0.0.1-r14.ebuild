# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="82b3c50bfaebf2267ee1c841df31aae1ba5e0061"
CROS_WORKON_TREE="ce15a766b4ca9cee805e154605620aec1f26fdeb"
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
	insinto /usr/include/tpm2
	doins BaseTypes.h
	doins ExecCommand_fp.h
	doins GetCommandCodeString_fp.h
	doins Implementation.h
	doins Platform.h
	doins TPMB.h
	doins TPM_Types.h
	doins Tpm.h
	doins TpmBuildSwitches.h
	doins TpmError.h
	doins _TPM_Init_fp.h
	doins bool.h
	doins swap.h
	doins tpm_generated.h
}
