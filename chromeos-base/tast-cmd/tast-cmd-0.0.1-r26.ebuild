# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="113ea40182f6db495835e4be695a62619262f7e9"
CROS_WORKON_TREE="be6afb856b4ba79b829fef11593b77973946bb76"
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
