# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="v${PV}"
CROS_WORKON_PROJECT="external/github.com/google/go-cmp"
CROS_WORKON_DESTDIR="${S}/src/github.com/google/go-cmp"

CROS_GO_PACKAGES=(
	"github.com/google/go-cmp/..."
)

inherit cros-workon cros-go

DESCRIPTION="Package for comparing Go values in tests"
HOMEPAGE="https://github.com/google/go-cmp"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
