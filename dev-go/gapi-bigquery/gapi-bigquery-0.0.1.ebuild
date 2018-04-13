# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
# The dev-go/gapi* packages are all built from this repo.  They should
# be updated together.
CROS_WORKON_COMMIT="068431dcab1a5817548dd244d9795788a98329f4"
CROS_WORKON_PROJECT="external/github.com/google/google-api-go-client"
CROS_WORKON_DESTDIR="${S}/src/google.golang.org/api"

CROS_GO_PACKAGES=(
	"google.golang.org/api/bigquery/v2"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Auto-generated Google APIs for Go"
HOMEPAGE="https://github.com/google/google-api-go-client"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/gapi-gensupport
	dev-go/gapi-googleapi
	dev-go/net
"
RDEPEND="${DEPEND}"
