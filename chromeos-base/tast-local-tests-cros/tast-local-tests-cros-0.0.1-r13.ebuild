# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT=("7d7d34b06d06e30abc8cac9de56195706be93b60" "e17d6e12ed9b5a398cff1569c96e60a627fd861d")
CROS_WORKON_TREE=("de0a86653150e21e0dc43a12c02370b658970bea" "2575c8f457dca8e76841903f7caccec82a7fae2d")
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
