# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="f52d1811a62927559de87708c8913c1650ce4f26"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="sync"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/sync"

CROS_GO_PACKAGES=(
	"golang.org/x/sync/errgroup"
	"golang.org/x/sync/semaphore"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Additional Go concurrency primitives"
HOMEPAGE="https://golang.org/x/sync"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND="dev-go/net"
