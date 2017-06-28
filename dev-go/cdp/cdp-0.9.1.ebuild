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
	"github.com/mafredri/cdp/protocol"
	"github.com/mafredri/cdp/protocol/accessibility"
	"github.com/mafredri/cdp/protocol/animation"
	"github.com/mafredri/cdp/protocol/applicationcache"
	"github.com/mafredri/cdp/protocol/browser"
	"github.com/mafredri/cdp/protocol/cachestorage"
	"github.com/mafredri/cdp/protocol/console"
	"github.com/mafredri/cdp/protocol/css"
	"github.com/mafredri/cdp/protocol/database"
	"github.com/mafredri/cdp/protocol/debugger"
	"github.com/mafredri/cdp/protocol/deviceorientation"
	"github.com/mafredri/cdp/protocol/dom"
	"github.com/mafredri/cdp/protocol/domdebugger"
	"github.com/mafredri/cdp/protocol/domsnapshot"
	"github.com/mafredri/cdp/protocol/domstorage"
	"github.com/mafredri/cdp/protocol/emulation"
	"github.com/mafredri/cdp/protocol/heapprofiler"
	"github.com/mafredri/cdp/protocol/indexeddb"
	"github.com/mafredri/cdp/protocol/input"
	"github.com/mafredri/cdp/protocol/inspector"
	"github.com/mafredri/cdp/protocol/internal"
	"github.com/mafredri/cdp/protocol/io"
	"github.com/mafredri/cdp/protocol/layertree"
	"github.com/mafredri/cdp/protocol/log"
	"github.com/mafredri/cdp/protocol/memory"
	"github.com/mafredri/cdp/protocol/network"
	"github.com/mafredri/cdp/protocol/overlay"
	"github.com/mafredri/cdp/protocol/page"
	"github.com/mafredri/cdp/protocol/profiler"
	"github.com/mafredri/cdp/protocol/runtime"
	"github.com/mafredri/cdp/protocol/schema"
	"github.com/mafredri/cdp/protocol/security"
	"github.com/mafredri/cdp/protocol/serviceworker"
	"github.com/mafredri/cdp/protocol/storage"
	"github.com/mafredri/cdp/protocol/systeminfo"
	"github.com/mafredri/cdp/protocol/target"
	"github.com/mafredri/cdp/protocol/tethering"
	"github.com/mafredri/cdp/protocol/tracing"
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
