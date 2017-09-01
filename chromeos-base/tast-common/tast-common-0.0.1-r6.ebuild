# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="1686f5f2edb37decda7d9146e2a0fbe936907f7a"
CROS_WORKON_TREE="37a602e9ecf49077b505f41e3ad3d61d82156058"
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
