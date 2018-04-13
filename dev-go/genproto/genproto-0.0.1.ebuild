# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="2b5a72b8730b0b16380010cfe5286c42108d88e7"
CROS_WORKON_PROJECT="external/github.com/google/go-genproto"
CROS_WORKON_DESTDIR="${S}/src/google.golang.org/genproto"

CROS_GO_PACKAGES=(
	"google.golang.org/genproto/googleapis/api/annotations"
	"google.golang.org/genproto/googleapis/api/distribution"
	"google.golang.org/genproto/googleapis/api/label"
	"google.golang.org/genproto/googleapis/api/metric"
	"google.golang.org/genproto/googleapis/api/monitoredres"
	"google.golang.org/genproto/googleapis/devtools/cloudtrace/v2"
	"google.golang.org/genproto/googleapis/iam/v1"
	"google.golang.org/genproto/googleapis/monitoring/v3"
	"google.golang.org/genproto/googleapis/rpc/code"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/genproto/googleapis/rpc/status"
	"google.golang.org/genproto/protobuf/field_mask"
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
