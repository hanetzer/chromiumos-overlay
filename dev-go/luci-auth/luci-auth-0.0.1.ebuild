# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
# The dev-go/luci-* packages are all built from this repo.  They should
# be updated together.
CROS_WORKON_COMMIT="cd0af436c99af77e8b752efda9d38413290faf66"
CROS_WORKON_PROJECT="infra/luci/luci-go"
CROS_WORKON_DESTDIR="${S}/src/go.chromium.org/luci"

CROS_GO_PACKAGES=(
	"go.chromium.org/luci/auth"
	"go.chromium.org/luci/auth/internal"
	"go.chromium.org/luci/auth/integration/localauth/rpcs"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="LUCI Go auth library"
HOMEPAGE="https://chromium.googlesource.com/infra/luci/luci-go/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/gcp-compute
	dev-go/grpc
	dev-go/luci-common
	dev-go/net
	dev-go/oauth2
"
RDEPEND="${DEPEND}"
