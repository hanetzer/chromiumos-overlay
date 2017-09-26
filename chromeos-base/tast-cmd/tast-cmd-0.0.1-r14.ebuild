# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="1051336cfcd77b7916950e1cab6bf552fc1af7ad"
CROS_WORKON_TREE="4c08e253d2775263f9eaa1eee988f1b9bed2053c"
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
