# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="feac077c1d96d81f9c1c0b5253d0223b0a2d9448"
CROS_WORKON_TREE="bbc7c7346a37a9f78fd7d03e852a3df987ca180e"

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
