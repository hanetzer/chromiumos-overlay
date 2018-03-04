# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT=("937b024e76e0ac259e502933ff1b7092105fb630" "e1f4ce3913b4aade5f10e434189e8a1060e05362")
CROS_WORKON_TREE=("fe8c9d538845a2e9cf19339a8524e101f0be233e" "6861134e54b44a4aaa7900e0c7bb578da9545839")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/tast"
	"chromiumos/platform/tast-tests"
)
CROS_WORKON_LOCALNAME=(
	"tast"
	"tast-tests"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/tast-tests"
)
# TODO(derat): Delete this hack after https://crbug.com/812032 is addressed.
CROS_GO_WORKSPACE="${S}:${S}/tast-tests"

CROS_GO_TEST=(
	# Test support packages that live above local/bundles/.
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
