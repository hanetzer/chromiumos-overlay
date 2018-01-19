# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="7374bead60a5aa76d316ddcb54c4983873524acd"
CROS_WORKON_TREE="4a9f8b2e4fab8666541cbbd1ea43a381e21a9ab6"
CROS_WORKON_PROJECT="chromiumos/platform/tast-tests"
CROS_WORKON_LOCALNAME="tast-tests"

CROS_GO_BINARIES=(
	"chromiumos/tast/local/bundles/cros:/usr/libexec/tast/bundles/cros"
)

CROS_GO_TEST=(
	"chromiumos/tast/local/..."
)

inherit cros-go cros-workon

DESCRIPTION="Bundle of local integration tests for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast-tests/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	chromeos-base/tast-common
	dev-go/cdp
	dev-go/dbus
	dev-go/gopsutil
"
RDEPEND="!chromeos-base/tast-local-tests"

src_install() {
	cros-go_src_install

	# Install each category's data dir (with its full path within the src/
	# directory) under /usr/share/tast/data.
	pushd src || die "failed to pushd src"
	local datadir
	for datadir in chromiumos/tast/local/bundles/cros/*/data; do
		insinto "/usr/share/tast/data/$(dirname "${datadir}")"
		doins -r "${datadir}"
	done
	popd
}
