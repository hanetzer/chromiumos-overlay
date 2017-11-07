# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="d7953e107cda521b77285906d2b14496f7d9dc9f"
CROS_WORKON_TREE="d69ae7e48aad609c9637da805654920c4a39ecbe"
CROS_WORKON_PROJECT="chromiumos/platform/tast-tests"
CROS_WORKON_LOCALNAME="tast-tests"

CROS_GO_BINARIES=(
	"chromiumos/tast/local:local_tests"
)

CROS_GO_TEST=(
	"chromiumos/tast/local/..."
)

inherit cros-go cros-workon

DESCRIPTION="Local integration tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast-tests/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	chromeos-base/tast-common
	dev-go/cdp
	dev-go/dbus
"
RDEPEND=""

src_install() {
	cros-go_src_install

	# Install each category's data dir (with its full path within the src/
	# directory) under /usr/share/tast/data.
	pushd src || die "failed to pushd src"
	local datadir
	for datadir in chromiumos/tast/local/tests/*/data; do
		insinto "/usr/share/tast/data/$(dirname "${datadir}")"
		doins -r "${datadir}"
	done
	popd
}
