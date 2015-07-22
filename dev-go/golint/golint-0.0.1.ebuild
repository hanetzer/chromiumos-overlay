# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="1dc973e526beec42f14ad7273ad036751bd4a833"
CROS_WORKON_TREE="d46153dbbdc68ef1dde6c6661cccdb7eac1072b0"
CROS_WORKON_PROJECT="external/github.com/golang/lint"
CROS_WORKON_DESTDIR="${S}/src/github.com/golang/lint"

CROS_GO_BINARIES=(
	"github.com/golang/lint/golint"
)

inherit cros-workon cros-go

DESCRIPTION="A linter for Go source code"
HOMEPAGE="http://github.com/golang/lint"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/go-tools"
RDEPEND=""
