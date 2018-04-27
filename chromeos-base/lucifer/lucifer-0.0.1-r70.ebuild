# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_WORKON_COMMIT="3de076950e35056bc13479e2221041d3d214e345"
CROS_WORKON_TREE="71bfd5234f89db2c29a6eb38eba09d8a2d546e2a"
CROS_WORKON_PROJECT="chromiumos/infra/lucifer"
CROS_WORKON_LOCALNAME="../../infra/lucifer"

CROS_GO_BINARIES=(
	"lucifer/cmd/lucifer_run_job"
	"lucifer/cmd/lucifer_watcher"
	"lucifer/cmd/skylab_swarming_worker"
)

inherit cros-workon cros-go

DESCRIPTION="Chromium OS testing infrastructure"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/infra/lucifer/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/gcp-bigquery
	dev-go/go-sys
	dev-go/luci-swarming
	dev-go/luci-tsmon
	dev-go/opencensus
"
RDEPEND=""
