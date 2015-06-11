# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="637ff03502f3511d90e8d79cc1c52b3be01d6cd3"
CROS_WORKON_TREE="8398811b813ebc297c9a3774d5bff560b2d64ef1"
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
AUTOTEST_SERVER_SITE_TESTS=autotest/server

function src_compile {
	# for Makefile
	export VBOOT_DIR=${WORKDIR}/${P}
        export MINIMAL=1  # Makefile requires this for cross-compiling
	autotest_src_compile
}


