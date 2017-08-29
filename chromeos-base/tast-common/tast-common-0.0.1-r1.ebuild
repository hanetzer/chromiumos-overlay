# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="95b9f24a05433200b7d7bf29f3ef1dadd5a88afc"
CROS_WORKON_TREE="9a864797112761fa6ea56761311e37398a112deb"
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
