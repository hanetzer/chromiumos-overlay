# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="fdc9e635145ae97e6c2cb777c48305600cf515cb"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="oauth2"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/oauth2"

CROS_GO_PACKAGES=(
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/internal"
	"golang.org/x/oauth2/jws"
	"golang.org/x/oauth2/jwt"
	"golang.org/x/oauth2/google"
)

CROS_GO_TEST=(
	"golang.org/x/oauth2"
	#Flaky: "golang.org/x/oauth2/internal"
	"golang.org/x/oauth2/jws"
	"golang.org/x/oauth2/jwt"
	"golang.org/x/oauth2/google"
)

inherit cros-workon cros-go

DESCRIPTION="Go packages for oauth2"
HOMEPAGE="https://golang.org/x/oauth2"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/gcp-compute"
RDEPEND="${DEPEND}"
