# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="8250e8019bcf6a3e0a301c80771ebd81b58a8894"
CROS_WORKON_TREE="fc88da9f1a02479989128f4a1de6cb2c01b49a22"
CROS_WORKON_PROJECT="chromiumos/platform/tast"
CROS_WORKON_LOCALNAME="tast"

CROS_GO_PACKAGES=(
	"chromiumos/tast/common/control"
	"chromiumos/tast/common/host"
	"chromiumos/tast/common/runner"
	"chromiumos/tast/common/testing"
	"chromiumos/tast/common/testing/attr"
	"chromiumos/tast/common/testutil"
)

CROS_GO_TEST=(
	"chromiumos/tast/common/..."
)

inherit cros-go cros-workon

DESCRIPTION="Shared packages for integration testing"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="dev-go/crypto"
