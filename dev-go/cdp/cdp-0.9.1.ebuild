# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="v${PV}"
CROS_WORKON_PROJECT="external/github.com/mafredri/cdp"
CROS_WORKON_DESTDIR="${S}/src/github.com/mafredri/cdp"

CROS_GO_PACKAGES=(
	"github.com/mafredri/cdp"
	"github.com/mafredri/cdp/devtool"
	"github.com/mafredri/cdp/protocol/..."
	"github.com/mafredri/cdp/rpcc"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Type-safe bindings for the Chrome Debugging Protocol written in Go"
HOMEPAGE="https://github.com/mafredri/cdp"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="binchecks strip"

DEPEND="test? ( dev-go/sync )"
RDEPEND="dev-go/websocket"
