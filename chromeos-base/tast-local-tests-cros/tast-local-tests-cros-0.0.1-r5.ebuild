# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="7374bead60a5aa76d316ddcb54c4983873524acd"
CROS_WORKON_TREE="4a9f8b2e4fab8666541cbbd1ea43a381e21a9ab6"
CROS_WORKON_PROJECT="chromiumos/platform/tast-tests"
CROS_WORKON_LOCALNAME="tast-tests"

# Test support packages that live above local/bundles/.
CROS_GO_TEST=(
	"chromiumos/tast/local/..."
)

inherit cros-workon tast-bundle

DESCRIPTION="Bundle of local integration tests for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast-tests/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	dev-go/cdp
	dev-go/dbus
	dev-go/gopsutil
"
RDEPEND="!chromeos-base/tast-local-tests"
