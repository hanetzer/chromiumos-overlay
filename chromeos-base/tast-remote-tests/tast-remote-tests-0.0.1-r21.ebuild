# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f93a6b0dd46dabe5cf7bf6670b2472bc9a408ea5"
CROS_WORKON_TREE="2f91643a5bfa9961f0ff0f18abfec2f4f56b68d5"
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
