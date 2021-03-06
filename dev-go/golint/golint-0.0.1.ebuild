# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="c5fb716d6688a859aae56d26d3e6070808df29f7"
CROS_WORKON_PROJECT="external/github.com/golang/lint"
CROS_WORKON_DESTDIR="${S}/src/github.com/golang/lint"

CROS_GO_BINARIES=(
	"github.com/golang/lint/golint"
)

inherit cros-workon cros-go

DESCRIPTION="A linter for Go source code"
HOMEPAGE="https://github.com/golang/lint"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/go-tools"
RDEPEND=""
