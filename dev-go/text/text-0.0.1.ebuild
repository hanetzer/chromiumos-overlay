# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="1cbadb444a806fd9430d14ad08967ed91da4fa0a"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="text"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/text"

CROS_GO_PACKAGES=(
	"golang.org/x/text/secure/bidirule"
	"golang.org/x/text/transform"
	"golang.org/x/text/unicode/bidi"
	"golang.org/x/text/unicode/norm"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Go text processing support"
HOMEPAGE="https://golang.org/x/text"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
