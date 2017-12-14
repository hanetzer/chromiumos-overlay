# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="v${PV}"
CROS_WORKON_PROJECT="external/github.com/shirou/gopsutil"
CROS_WORKON_DESTDIR="${S}/src/github.com/shirou/gopsutil"

CROS_GO_PACKAGES=(
	"github.com/shirou/gopsutil/cpu"
	"github.com/shirou/gopsutil/disk"
	"github.com/shirou/gopsutil/host"
	"github.com/shirou/gopsutil/internal/..."
	"github.com/shirou/gopsutil/load"
	"github.com/shirou/gopsutil/mem"
	"github.com/shirou/gopsutil/net"
	"github.com/shirou/gopsutil/process"
)

CROS_GO_TEST=(
	"github.com/shirou/gopsutil/cpu"
	"github.com/shirou/gopsutil/disk"
	# host fails due to missing /var/run/utmp in chroot.
	"github.com/shirou/gopsutil/internal/..."
	"github.com/shirou/gopsutil/load"
	# mem, net, and process require github.com/stretchr/testify/assert.
)

inherit cros-workon cros-go

DESCRIPTION="Cross-platform lib for process and system monitoring in Go"
HOMEPAGE="https://github.com/shirou/gopsutil"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="binchecks strip"

DEPEND="test? ( dev-go/go-sys )"
RDEPEND="dev-go/go-sys"
