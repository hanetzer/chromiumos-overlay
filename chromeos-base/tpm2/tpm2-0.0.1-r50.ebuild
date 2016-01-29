# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="0994ac92f207a6dd4cb6b9af4d9d39d6bc083d59"
CROS_WORKON_TREE="b85ac985052bd3ccc2e4974cfb82878795fbe1a2"
CROS_WORKON_PROJECT="chromiumos/third_party/tpm2"
CROS_WORKON_LOCALNAME="../third_party/tpm2"

inherit cros-workon toolchain-funcs

DESCRIPTION="TPM2.0 library"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-libs/openssl"

src_compile() {
	tc-export CC AR RANLIB
	emake
}

src_install() {
	dolib.a build/libtpm2.a
	insinto /usr/include/tpm2
	doins BaseTypes.h
	doins Capabilities.h
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
	doins tpm_types.h
}
