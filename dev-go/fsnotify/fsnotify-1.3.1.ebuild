# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Use ebuild version to checkout the corresponding tag.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="v${PV}"
CROS_WORKON_PROJECT="external/github.com/fsnotify/fsnotify"
CROS_WORKON_DESTDIR="${S}/src/github.com/fsnotify/fsnotify"

CROS_GO_PACKAGES=(
	"github.com/fsnotify/fsnotify"
)

inherit cros-workon cros-go

DESCRIPTION="File system notifications for Go"
HOMEPAGE="https://github.com/fsnotify/fsnotify"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RESTRICT="binchecks strip"

DEPEND=""
RDEPEND="dev-go/go-sys"
