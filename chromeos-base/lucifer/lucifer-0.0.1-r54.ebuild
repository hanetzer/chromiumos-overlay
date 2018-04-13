# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_WORKON_COMMIT="be80d96cc50d8b15d108d248e5cad6461021780a"
CROS_WORKON_TREE="a335b1b31024706af6235fa8557bdfc4eb19a839"
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
	dev-go/luci-tsmon
	dev-go/opencensus
"
RDEPEND=""
