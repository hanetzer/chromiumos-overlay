# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="51854aba4682903632d14998d47781fe34e62a02"
CROS_WORKON_TREE="3d85ed2d14a517b8c4b570ef5690ab8d3f1a3235"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="net"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/net"

CROS_GO_PACKAGES=(
	"golang.org/x/net/context"
)

inherit cros-workon cros-go

DESCRIPTION="Go supplementary network libraries"
HOMEPAGE="https://golang.org/x/net"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
