# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="4928733085e9593b7dcdb0fe268b20e1e1184b6d"
CROS_WORKON_PROJECT="external/github.com/google/gofountain"
CROS_WORKON_DESTDIR="${S}/src/github.com/google/gofountain"

CROS_GO_PACKAGES=(
	"github.com/google/gofountain"
)

inherit cros-workon cros-go

DESCRIPTION="Go implementation of various fountain codes. Luby Transform, Online codes, Raptor code."
HOMEPAGE="https://github.com/google/gofountain"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
