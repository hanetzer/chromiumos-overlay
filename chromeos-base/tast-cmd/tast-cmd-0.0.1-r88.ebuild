# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="0a4c9d59f33ce83a683fa8a1c72fd8d6f88a286d"
CROS_WORKON_TREE="9f50eb2001a1a7a7f968bf57a1b286f53f0170e0"
CROS_WORKON_PROJECT="chromiumos/platform/tast"
CROS_WORKON_LOCALNAME="tast"

CROS_GO_BINARIES=(
	"chromiumos/cmd/remote_test_runner"
	"chromiumos/cmd/tast"
)

CROS_GO_VERSION="${PF}"

CROS_GO_TEST=(
	"chromiumos/cmd/tast/..."
	# Also test common code.
	"chromiumos/tast/..."
)

inherit cros-go cros-workon

DESCRIPTION="Host executables for running integration tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	dev-go/crypto
	dev-go/subcommands
"
RDEPEND="
	app-arch/tar
	app-arch/xz-utils
	chromeos-base/google-breakpad
	net-misc/gsutil
	!chromeos-base/tast-common
"
