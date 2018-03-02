# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="v${PV}"
CROS_WORKON_PROJECT="external/github.com/census-instrumentation/opencensus-go"
CROS_WORKON_DESTDIR="${S}/src/go.opencensus.io"

CROS_GO_PACKAGES=(
	"go.opencensus.io/exporter/stackdriver"
	"go.opencensus.io/internal"
	"go.opencensus.io/internal/tagencoding"
	"go.opencensus.io/plugin/ochttp"
	"go.opencensus.io/plugin/ochttp/propagation/b3"
	"go.opencensus.io/stats"
	"go.opencensus.io/stats/internal"
	"go.opencensus.io/stats/view"
	"go.opencensus.io/tag"
	"go.opencensus.io/trace"
	"go.opencensus.io/trace/propagation"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="A stats collection and distributed tracing framework"
HOMEPAGE="http://opencensus.io/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/gapi-bundler
	dev-go/gcp-monitoring
	dev-go/gcp-trace
	dev-go/genproto
	dev-go/protobuf
"
RDEPEND="${DEPEND}"
