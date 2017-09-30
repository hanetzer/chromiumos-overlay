# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="b7dab7f67ba182f63cab51d145d7acad6f7737bb"
CROS_WORKON_TREE="73a025b9ab406a370fa775bbab9089b6ee18351d"
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
