# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="183e37b35d1a075e3781cba36c8451cff88ee0bf"
CROS_WORKON_TREE="547087dabd618cec094bcc8cf894add481f1ce5b"
CROS_WORKON_PROJECT="chromiumos/platform/tast"
CROS_WORKON_LOCALNAME="tast"

CROS_GO_BINARIES=(
	"chromiumos/cmd/tast"
)

CROS_GO_TEST=(
	"chromiumos/cmd/tast/..."
)

inherit cros-go cros-workon

DESCRIPTION="Host executable for running integration tests"
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
	chromeos-base/google-breakpad
"