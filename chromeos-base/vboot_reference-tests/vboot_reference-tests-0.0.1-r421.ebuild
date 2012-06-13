# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8b6da26a6e5978a43233f7a43c7bab5889d3817a"
CROS_WORKON_TREE="30d54d0daedca8a126a61ac7e435c0423e768c54"

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
