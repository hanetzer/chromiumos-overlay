# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="77f55ca1cd282ac6c540ea3a8bacbc35c2600d60"
CROS_WORKON_TREE="fe5a9950810e484603b95ecbf7dff6fe743e037d"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-workon autotest

DESCRIPTION="TPM firmware tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"
DEPEND="app-crypt/trousers
        chromeos-base/tpm"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

IUSE_TESTS="
	+tests_hardware_TPMFirmware
	+tests_hardware_TPMFirmwareServer
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=vboot_reference

# path from root of repo
AUTOTEST_CLIENT_SITE_TESTS=autotest/client

function src_compile {
	# for Makefile
	export VBOOT_DIR=${WORKDIR}/${P}
        export MINIMAL=1  # Makefile requires this for cross-compiling
	autotest_src_compile
}
