# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="d97da41d56e409e6e41bc07a3cdad80b04840476"
CROS_WORKON_TREE="8ec9405a24e6148b9e6846520f0243cc05610707"
CROS_WORKON_PROJECT="chromiumos/platform/tast"
CROS_WORKON_LOCALNAME="tast"

CROS_GO_PACKAGES=(
	"chromiumos/tast/..."
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go cros-workon

DESCRIPTION="Shared packages for integration testing"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="dev-go/crypto"
