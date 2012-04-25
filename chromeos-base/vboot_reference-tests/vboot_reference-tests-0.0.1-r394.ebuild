# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="916cf1e977f02f54dff6ab8f25c03a94c9657ef0"
CROS_WORKON_TREE="5812b5c97b378a92daa543282c9b29664855ca54"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-workon autotest

DESCRIPTION="vboot tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

IUSE_TESTS="
	+tests_firmware_VbootCrypto
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=vboot_reference

# path from root of repo
AUTOTEST_CLIENT_SITE_TESTS=autotest/client

function src_compile {
	# for Makefile
	export VBOOT_SRC_DIR=${WORKDIR}/${P}
	autotest_src_compile
}
