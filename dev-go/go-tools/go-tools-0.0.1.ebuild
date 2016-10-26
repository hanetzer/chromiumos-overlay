# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="605d5bf7f53c886f0b33afe425db6664d1ed899c"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="tools"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/tools"

CROS_GO_PACKAGES=(
	"golang.org/x/tools/go/exact"
	"golang.org/x/tools/go/types"
	"golang.org/x/tools/go/gcimporter"
)

# The tests for "golang.org/x/tools/go/types" look for ${GOROOT}/test
# directory, which we do not install in dev-lang/go.
CROS_GO_TEST=(
	"golang.org/x/tools/go/exact"
	"golang.org/x/tools/go/gcimporter"
)

CROS_GO_BINARIES=(
	"golang.org/x/tools/cmd/godoc"
	"golang.org/x/tools/cmd/vet:govet"
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
