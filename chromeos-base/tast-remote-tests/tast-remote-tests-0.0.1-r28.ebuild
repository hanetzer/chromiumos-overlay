# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="79bffba38e75aebd4463e590d0788ba24cc072e0"
CROS_WORKON_TREE="ff89194f67b17713ae600b92d01fc170a306c6f3"
CROS_WORKON_PROJECT="chromiumos/platform/tast-tests"
CROS_WORKON_LOCALNAME="tast-tests"

CROS_GO_BINARIES=(
	"chromiumos/cmd/remote_tests"
)

# Support packages live outside of cmd/.
CROS_GO_TEST=(
	"chromiumos/tast/remote/..."
)

inherit cros-go cros-workon

DESCRIPTION="Remote integration tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast-tests/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="chromeos-base/tast-common"
RDEPEND=""
