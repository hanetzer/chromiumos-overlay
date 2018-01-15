# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="36dcfcbf3b930397bfef421bd92e0cdd86ba0ba2"
CROS_WORKON_TREE="0653da48e3304d8ed1a8c71762ace7b02c3741e7"
CROS_WORKON_PROJECT="chromiumos/platform/tast"
CROS_WORKON_LOCALNAME="tast"

CROS_GO_BINARIES=(
	"chromiumos/cmd/remote_test_runner"
	"chromiumos/cmd/tast"
)

CROS_GO_TEST=(
	"chromiumos/cmd/tast/..."
)

inherit cros-go cros-workon

DESCRIPTION="Host executables for running integration tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	chromeos-base/tast-common
	dev-go/subcommands
"
RDEPEND="
	app-arch/xz-utils
	chromeos-base/google-breakpad
	net-misc/gsutil
"
