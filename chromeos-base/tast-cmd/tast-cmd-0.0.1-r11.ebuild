# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="af086d77fe23109b085d9d292dfa5c344d76cf43"
CROS_WORKON_TREE="b0923ad5e03d4614ed7c1f2c6c1c3ef0a8201eac"
CROS_WORKON_PROJECT="chromiumos/platform/tast"
CROS_WORKON_LOCALNAME="tast"

CROS_GO_BINARIES=(
	"chromiumos/tast/cmd:tast"
)

CROS_GO_TEST=(
	"chromiumos/tast/cmd/..."
)

inherit cros-go cros-workon

DESCRIPTION="Host executable for running integration tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	chromeos-base/tast-common
	dev-go/subcommands
"
RDEPEND=""
