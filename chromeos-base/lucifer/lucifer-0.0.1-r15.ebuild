# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_WORKON_COMMIT="e2f0e880ec83b82272aab92de2abb723e58467a4"
CROS_WORKON_TREE="2574d97cc203b93b37f60f0cc6a7c7d9e211b989"
CROS_WORKON_PROJECT="chromiumos/infra/lucifer"
CROS_WORKON_LOCALNAME="../../infra/lucifer"

CROS_GO_BINARIES=(
	"chromiumos/infra/lucifer/cmd/lucifer_run_job"
	"chromiumos/infra/lucifer/cmd/lucifer_watcher"
)

inherit cros-workon cros-go

DESCRIPTION="Chromium OS testing infrastructure"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/infra/lucifer/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
