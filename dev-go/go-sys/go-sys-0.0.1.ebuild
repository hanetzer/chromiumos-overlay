# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="a646d33e2ee3172a661fc09bca23bb4889a41bc8"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="sys"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/sys"

CROS_GO_PACKAGES=(
	"golang.org/x/sys/unix"
)

CROS_GO_TEST=(
	"golang.org/x/sys/unix"
)

inherit cros-workon cros-go

DESCRIPTION="Go packages for low-level interaction with the operating system"
HOMEPAGE="https://golang.org/x/sys"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
