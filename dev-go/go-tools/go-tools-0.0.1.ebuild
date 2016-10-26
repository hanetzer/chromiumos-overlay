# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="0db92ca630c08f00e3ba4b5abea93836ca04b42e"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="tools"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/tools"

CROS_GO_PACKAGES=(
	"golang.org/x/tools/go/gcimporter15"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

CROS_GO_BINARIES=(
	"golang.org/x/tools/cmd/godoc"
	"golang.org/x/tools/cmd/guru:goguru"
)

inherit cros-workon cros-go

DESCRIPTION="Packages and tools that support the Go programming language"
HOMEPAGE="https://golang.org/x/tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
