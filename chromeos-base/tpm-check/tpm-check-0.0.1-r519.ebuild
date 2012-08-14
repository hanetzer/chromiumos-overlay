# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="b57b8c3deae3dad870d8785fed46daabbdf35ea9"
CROS_WORKON_TREE="278ac73368379c79d8665e0fc374613f05e504ba"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-workon autotest

DESCRIPTION="tpm check test"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

IUSE_TESTS="
	+tests_hardware_TPMCheck
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=vboot_reference

# path from root of repo
AUTOTEST_CLIENT_SITE_TESTS=autotest/client
