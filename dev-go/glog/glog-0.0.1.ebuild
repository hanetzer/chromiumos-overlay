# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="44145f04b68cf362d9c4df2182967c2275eaefed"
CROS_WORKON_TREE="ff88a8670fe235f678315b4ede0378ba88585a54"
CROS_WORKON_PROJECT="external/github.com/golang/glog"
CROS_WORKON_DESTDIR="${S}/src/github.com/golang/glog"

CROS_GO_PACKAGES=(
	"github.com/golang/glog"
)

inherit cros-workon cros-go

DESCRIPTION="Leveled execution logs for Go"
HOMEPAGE="https://github.com/golang/glog"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
