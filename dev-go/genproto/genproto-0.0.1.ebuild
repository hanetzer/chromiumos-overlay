# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="1e559d0a00eef8a9a43151db4665280bd8dd5886"
CROS_WORKON_PROJECT="external/github.com/google/go-genproto"
CROS_WORKON_DESTDIR="${S}/src/google.golang.org/genproto"

CROS_GO_PACKAGES=(
	"google.golang.org/genproto/googleapis/rpc/code"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/genproto/googleapis/rpc/status"
)

inherit cros-workon cros-go

DESCRIPTION="Go generated proto packages"
HOMEPAGE="https://github.com/googleapis/googleapis/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip test"

DEPEND=""
RDEPEND="dev-go/protobuf"
