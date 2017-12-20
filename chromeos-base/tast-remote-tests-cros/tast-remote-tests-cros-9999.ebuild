# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_PROJECT="chromiumos/platform/tast-tests"
CROS_WORKON_LOCALNAME="tast-tests"

CROS_GO_BINARIES=(
	"chromiumos/tast/remote/bundles/cros:/usr/libexec/tast/bundles/cros"
)

# Support packages live outside of cmd/.
CROS_GO_TEST=(
	"chromiumos/tast/remote/..."
)

inherit cros-go cros-workon

DESCRIPTION="Bundle of remote integration tests for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast-tests/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE=""

DEPEND="
	chromeos-base/tast-common
	dev-go/cdp
	dev-go/dbus
	dev-go/gopsutil
"
RDEPEND=""
