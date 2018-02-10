# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="v${PV}"
CROS_WORKON_PROJECT="external/github.com/googleapis/gax-go"
CROS_WORKON_DESTDIR="${S}/src/github.com/googleapis/gax-go"

CROS_GO_PACKAGES=(
	"github.com/googleapis/gax-go"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Google API Extensions for Go"
HOMEPAGE="https://github.com/googleapis/gax-go"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/grpc"
RDEPEND="${DEPEND}"
