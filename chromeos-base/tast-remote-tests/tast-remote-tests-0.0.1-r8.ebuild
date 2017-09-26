# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="5ab7ca55f15bd26785129fc714780abc4f8603c8"
CROS_WORKON_TREE="e0f0839d8ca79abe6ae9248feee7d91334004ccb"
CROS_WORKON_PROJECT="chromiumos/platform/tast-tests"
CROS_WORKON_LOCALNAME="tast-tests"

CROS_GO_BINARIES=(
	"chromiumos/tast/remote:remote_tests"
)

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
